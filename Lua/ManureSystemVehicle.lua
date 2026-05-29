--
-- SprayerSectionControl
--
-- # author:    Rival (FS19 original)
-- # rewrite:   FS22 native API
-- # version:   1.0.0.0
-- # date:      2026
--

SprayerSectionControl = {}
SprayerSectionControl.modDirectory = g_currentModDirectory
SprayerSectionControl.MOD_NAME = g_currentModName

-- ==================== REJESTRACJA ====================

function SprayerSectionControl.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Sprayer, specializations)
        and SpecializationUtil.hasSpecialization(WorkArea, specializations)
end

function SprayerSectionControl.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", SprayerSectionControl)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad",                 SprayerSectionControl)
    SpecializationUtil.registerEventListener(vehicleType, "onPostLoad",             SprayerSectionControl)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate",               SprayerSectionControl)
    SpecializationUtil.registerEventListener(vehicleType, "onTurnedOn",             SprayerSectionControl)
    SpecializationUtil.registerEventListener(vehicleType, "onTurnedOff",            SprayerSectionControl)
    SpecializationUtil.registerEventListener(vehicleType, "onAIImplementStart",     SprayerSectionControl)
end

function SprayerSectionControl.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "processSprayerArea", SprayerSectionControl.processSprayerArea)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "getSprayerUsage",    SprayerSectionControl.getSprayerUsage)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "removeActionEvents", SprayerSectionControl.removeActionEvents)
end

function SprayerSectionControl.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "getSprayerFullWidth",           SprayerSectionControl.getSprayerFullWidth)
    SpecializationUtil.registerFunction(vehicleType, "getActiveSprayerSectionsWidth", SprayerSectionControl.getActiveSprayerSectionsWidth)
    SpecializationUtil.registerFunction(vehicleType, "changeSectionState",            SprayerSectionControl.changeSectionState)
    SpecializationUtil.registerFunction(vehicleType, "toggleAutomaticMode",           SprayerSectionControl.toggleAutomaticMode)
end

-- ==================== LADOWANIE ====================

function SprayerSectionControl:onLoad(savegame)
    local spec = {}
    spec.sections        = {}
    spec.isSSCReady      = false
    spec.isAutomaticMode = true
    spec.hudActive       = true

    local xmlFile = self.xmlFile

    if not xmlFile:hasProperty("vehicle.sprayerSectionControl") then
        self.spec_ssc = spec
        return
    end

    spec.isSSCReady = true

    local i = 0
    while true do
        local key = string.format("vehicle.sprayerSectionControl.sections.section(%d)", i)

        if not xmlFile:hasProperty(key) then
            break
        end

        i = i + 1

        local workAreaId     = xmlFile:getValue(key .. "#workAreaId")
        local effectNodeStr  = xmlFile:getValue(key .. "#effectNodeId") or ""
        local effectNodes    = StringUtil.splitString(" ", StringUtil.trim(effectNodeStr))
        local startNodeStr   = xmlFile:getValue(key .. "#testAreaStartNode")
        local widthNodeStr   = xmlFile:getValue(key .. "#testAreaWidthNode")
        local heightNodeStr  = xmlFile:getValue(key .. "#testAreaHeightNode")
        local workingWidth   = xmlFile:getValue(key .. "#workingWidth") or 3

        local testAreaStart  = I3DUtil.indexToObject(self.components, startNodeStr,  self.i3dMappings)
        local testAreaWidth  = I3DUtil.indexToObject(self.components, widthNodeStr,  self.i3dMappings)
        local testAreaHeight = I3DUtil.indexToObject(self.components, heightNodeStr, self.i3dMappings)

        if workAreaId == nil and self.spec_workArea ~= nil and self.spec_workArea.workAreas[i] ~= nil then
            workAreaId = i
        end

        if workAreaId ~= nil and #effectNodes > 0 and testAreaStart ~= nil and testAreaWidth ~= nil and testAreaHeight ~= nil then
            spec.sections[i] = {
                id             = i,
                workAreaId     = workAreaId,
                effectNodes    = effectNodes,
                testAreaStart  = testAreaStart,
                testAreaWidth  = testAreaWidth,
                testAreaHeight = testAreaHeight,
                workingWidth   = workingWidth,
                active         = true,
                sprayType      = nil
            }

            if self.spec_workArea ~= nil and self.spec_workArea.workAreas[workAreaId] ~= nil then
                self.spec_workArea.workAreas[workAreaId].sscId = i
                spec.sections[i].sprayType = self.spec_workArea.workAreas[workAreaId].sprayType
            end
        else
            print(string.format("[SSC] Warning: Nieprawidlowa konfiguracja sekcji '%s' w '%s'", key, self.configFileName))
        end
    end

    if #spec.sections == 0 then
        spec.isSSCReady = false
        print(string.format("[SSC] Warning: Brak poprawnych sekcji w '%s' - SSC wylaczone", self.configFileName))
    else
        print(string.format("[SSC] Zaladowano %d sekcji dla '%s'", #spec.sections, self.configFileName))
    end

    self.spec_ssc = spec
end

function SprayerSectionControl:onPostLoad(savegame)
    local spec = self.spec_ssc
    if spec == nil or not spec.isSSCReady then return end

    if g_client ~= nil and g_client.serverStreamId ~= nil and g_client.serverStreamId ~= 0 then
        print("[SSC] Tryb multiplayer - korygowanie pozycji testArea")
        for _, section in pairs(spec.sections) do
            local x, y, z = getTranslation(section.testAreaStart)
            setTranslation(section.testAreaStart, x, y, z + 0.8)
            x, y, z = getTranslation(section.testAreaWidth)
            setTranslation(section.testAreaWidth, x, y, z + 0.8)
        end
    end
end

-- ==================== AKTUALIZACJA ====================

function SprayerSectionControl:onUpdate(dt)
    local spec = self.spec_ssc
    if spec == nil or not spec.isSSCReady then return end
    if not spec.isAutomaticMode then return end
    if not self:getIsTurnedOn() then return end
    if self:getIsAIActive() then return end
    if #spec.sections == 0 then return end

    for _, section in pairs(spec.sections) do
        local sActive = true

        if section.sprayType ~= nil then
            local activeSprayType = self:getActiveSprayType()
            if activeSprayType ~= nil and section.sprayType ~= activeSprayType.index then
                sActive = false
            end
        end

        if sActive then
            local sx, _, sz = getWorldTranslation(section.testAreaStart)
            local wx, _, wz = getWorldTranslation(section.testAreaWidth)
            local hx, _, hz = getWorldTranslation(section.testAreaHeight)

            local area, _ = AIVehicleUtil.getAIFruitArea(sx, sz, wx, wz, hx, hz, self:getFieldCropsQuery())
            local newState = (area > 0) and (self:getLastSpeed() > 1)

            if section.active ~= newState then
                self:changeSectionState(section, newState)
            end
        end
    end
end

-- ==================== AKCJE / HUD ====================

function SprayerSectionControl:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    if not self.isClient then return end

    if self.spec_ssc == nil then self.spec_ssc = {} end

    local spec = self.spec_ssc
    if not spec.isSSCReady then return end

    spec.actionEvents = {}
    self:clearActionEventsTable(spec.actionEvents)

    if self:getIsActiveForInput(true, true) then
        if g_sprayerSectionControlHUD ~= nil then
            g_sprayerSectionControlHUD:setVehicle(self)
        end
        self:addActionEvent(spec.actionEvents, InputAction.SHOW_SSC_HUD,   self, SprayerSectionControl.processActionEvent, false, true, false, true)
        self:addActionEvent(spec.actionEvents, InputAction.SHOW_SSC_MOUSE, self, SprayerSectionControl.processActionEvent, false, true, false, true)
    end
end

function SprayerSectionControl:removeActionEvents(superFunc, ...)
    if g_sprayerSectionControlHUD ~= nil and g_sprayerSectionControlHUD:isVehicleActive(self) then
        g_sprayerSectionControlHUD:setVehicle(nil)
    end
    return superFunc(self, ...)
end

function SprayerSectionControl.processActionEvent(self, actionName, inputValue, callbackState, isAnalog)
    if g_sprayerSectionControlHUD == nil then return end

    if actionName == "SHOW_SSC_HUD" then
        g_sprayerSectionControlHUD.hudActive = not g_sprayerSectionControlHUD.hudActive
    elseif actionName == "SHOW_SSC_MOUSE" then
        if g_sprayerSectionControlHUD.hudActive then
            g_sprayerSectionControlHUD:toggleMouseCursor()
        end
    end
end

-- ==================== KONTROLA SEKCJI ====================

function SprayerSectionControl:changeSectionState(section, newState)
    if newState == nil then newState = not section.active end

    section.active = newState
    local activeSprayType = self:getActiveSprayType()

    if newState then
        if self:getIsTurnedOn() and self:getAreEffectsVisible() then
            for _, effectNodeId in pairs(section.effectNodes) do
                local idx = tonumber(effectNodeId)
                if activeSprayType ~= nil and activeSprayType.effects ~= nil then
                    g_effectManager:startEffect(activeSprayType.effects[idx])
                elseif self.spec_sprayer ~= nil and self.spec_sprayer.effects ~= nil then
                    g_effectManager:startEffect(self.spec_sprayer.effects[idx])
                end
            end
        end
        if g_sprayerSectionControlHUD ~= nil and g_sprayerSectionControlHUD.buttons ~= nil then
            if self:getIsTurnedOn() then
                g_sprayerSectionControlHUD.buttons[section.id]:setColor(unpack(g_sprayerSectionControlHUD.COLOR.GREEN))
            else
                g_sprayerSectionControlHUD.buttons[section.id]:setColor(unpack(g_sprayerSectionControlHUD.COLOR.YELLOW))
            end
        end
    else
        for _, effectNodeId in pairs(section.effectNodes) do
            local idx = tonumber(effectNodeId)
            if activeSprayType ~= nil and activeSprayType.effects ~= nil then
                g_effectManager:stopEffect(activeSprayType.effects[idx])
            end
            if self.spec_sprayer ~= nil and self.spec_sprayer.effects ~= nil then
                g_effectManager:stopEffect(self.spec_sprayer.effects[idx])
            end
        end
        if g_sprayerSectionControlHUD ~= nil and g_sprayerSectionControlHUD.buttons ~= nil then
            g_sprayerSectionControlHUD.buttons[section.id]:setColor(unpack(g_sprayerSectionControlHUD.COLOR.RED))
        end
    end
end

function SprayerSectionControl:toggleAutomaticMode(active)
    if active ~= nil then
        self.spec_ssc.isAutomaticMode = active
    else
        self.spec_ssc.isAutomaticMode = not self.spec_ssc.isAutomaticMode
    end

    if g_sprayerSectionControlHUD ~= nil and g_sprayerSectionControlHUD.autoModeButton ~= nil then
        if self.spec_ssc.isAutomaticMode then
            g_sprayerSectionControlHUD.autoModeButton:setColor(unpack(g_sprayerSectionControlHUD.COLOR.GREEN))
        else
            g_sprayerSectionControlHUD.autoModeButton:setColor(unpack(g_sprayerSectionControlHUD.COLOR.RED))
        end
    end
end

-- ==================== ZDARZENIA POJAZDU ====================

function SprayerSectionControl:onTurnedOn()
    local spec = self.spec_ssc
    if spec == nil or not spec.isSSCReady then return end

    for _, section in pairs(spec.sections) do
        if not section.active then
            for _, effectNodeId in pairs(section.effectNodes) do
                local idx = tonumber(effectNodeId)
                if self.spec_sprayer ~= nil and self.spec_sprayer.effects ~= nil then
                    g_effectManager:stopEffect(self.spec_sprayer.effects[idx])
                end
                if self.spec_sprayer ~= nil and self.spec_sprayer.sprayTypes ~= nil then
                    for _, sprayType in ipairs(self.spec_sprayer.sprayTypes) do
                        if sprayType.effects ~= nil then
                            g_effectManager:stopEffect(sprayType.effects[idx])
                        end
                    end
                end
            end
        else
            if g_sprayerSectionControlHUD ~= nil and g_sprayerSectionControlHUD.buttons ~= nil then
                g_sprayerSectionControlHUD.buttons[section.id]:setColor(unpack(g_sprayerSectionControlHUD.COLOR.GREEN))
            end
        end
    end
end

function SprayerSectionControl:onTurnedOff()
    local spec = self.spec_ssc
    if spec == nil or not spec.isSSCReady then return end

    for _, section in pairs(spec.sections) do
        if section.active then
            if g_sprayerSectionControlHUD ~= nil and g_sprayerSectionControlHUD.buttons ~= nil then
                g_sprayerSectionControlHUD.buttons[section.id]:setColor(unpack(g_sprayerSectionControlHUD.COLOR.YELLOW))
            end
        end
    end
end

function SprayerSectionControl:onAIImplementStart()
    local spec = self.spec_ssc
    if spec == nil or not spec.isSSCReady then return end

    for _, section in pairs(spec.sections) do
        self:changeSectionState(section, true)
    end
end

-- ==================== OBLICZENIA SZEROKOSCI ====================

function SprayerSectionControl:getSprayerFullWidth()
    local width = 0
    if self.spec_ssc ~= nil and self.spec_ssc.sections ~= nil then
        for _, section in pairs(self.spec_ssc.sections) do
            width = width + section.workingWidth
        end
    end
    return width
end

function SprayerSectionControl:getActiveSprayerSectionsWidth()
    local width = 0
    if self.spec_ssc ~= nil and self.spec_ssc.sections ~= nil then
        for _, section in pairs(self.spec_ssc.sections) do
            if section.active then
                width = width + section.workingWidth
            end
        end
    end
    return width
end

-- ==================== NADPISANE FUNKCJE ====================

function SprayerSectionControl:getSprayerUsage(superFunc, fillType, dt)
    local origUsage = superFunc(self, fillType, dt)
    if self.spec_ssc ~= nil and self.spec_ssc.isSSCReady then
        local fullWidth   = self:getSprayerFullWidth()
        local activeWidth = self:getActiveSprayerSectionsWidth()
        if fullWidth > 0 then
            return origUsage * activeWidth / fullWidth
        end
    end
    return origUsage
end

function SprayerSectionControl:processSprayerArea(superFunc, workArea, dt)
    if self.spec_ssc ~= nil and self.spec_ssc.isSSCReady then
        if workArea.sscId ~= nil then
            local section = self.spec_ssc.sections[workArea.sscId]
            if section ~= nil and not section.active then
                return 0, 0
            end
        end
    end
    return superFunc(self, workArea, dt)
end
