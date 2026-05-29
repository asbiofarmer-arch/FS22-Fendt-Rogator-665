----------------------------------------------------------------------------------------------------
-- loader
----------------------------------------------------------------------------------------------------
-- Purpose: Loads the SprayerSectionControl mod.
--
-- Copyright (c) Wopster, 2020
-- FS22 fix: corrected Lua/ path, removed g_soundManager, removed nil
----------------------------------------------------------------------------------------------------

local directory = g_currentModDirectory
local modName = g_currentModName

source(Utils.getFilename("Lua/SprayerSectionControl.lua", directory))
source(Utils.getFilename("Lua/SprayerSectionControlHUD.lua", directory))

local sscHud

local function isEnabled()
    return sscHud ~= nil
end

local function load(mission)
    assert(sscHud == nil)
    sscHud = SprayerSectionControlHUD:new(mission, g_i18n, g_inputBinding, g_gui, directory, modName)
    getfenv(0)["g_sprayerSectionControlHUD"] = sscHud
    addModEventListener(sscHud)
end

local function unload()
    if not isEnabled() then
        return
    end
    if sscHud ~= nil then
        sscHud:delete()
        sscHud = nil
        getfenv(0)["g_sprayerSectionControlHUD"] = nil
    end
end

local function init()
    FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, unload)
    Mission00.load = Utils.prependedFunction(Mission00.load, load)
end

init()