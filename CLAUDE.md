# CLAUDE.md — ASF22 Fendt Rogator 665

# Second Brain — kontekst projektu dla Claude

# Ostatnia aktualizacja: 31.05.2026

---

## KIM JESTEM

- Ucze sie moddingu FS22/FS25 — jestem poczatkujacym
- Rozumiem podstawy XML i skladnie Lua, ale nie pisze kodu od zera
- Potrafie czytac kod, rozumiem modDesc.xml na poziomie podstawowym
- Pracuje na Windows, glowne narzedzie terminalowe: PowerShell
- Git opanowalem prowadzony za reke

---

## ZASADY WSPOLPRACY — OBOWIAZKOWE

1. Pracujemy w oparciu o sprawdzone zrodla: GitHub, GIANTS Developer Network,
   ModHub FS22, Discord spolecznosci moderskich, publikacje renomowanych moderow
   i grup moderskich z wypracowanym autorytetem

2. Wyjasniaj zasade ZANIM pokazesz kod

3. Pokazuj kod z komentarzami krok po kroku

4. Porownuj ZLY vs DOBRY przyklad obok siebie

5. Dbaj o rzetelnosc, szczegolowosc i poprawnosc wszystkich danych.
   Chce rzetelnosci, poprawnosci, spojnosci w trzech językach: <en>, <de>, <fr>

6. ZLOTA ZASADA MODDINGU: w plikach XML, modDesc.xml, Lua, i3d
   uzywamy WYLACZNIE jezyka angielskiego — omijaj sztywne tlumaczenia
   i wszystkie znaki diakrytyczne. Do mnie zwracaj sie po polsku.

7. Dla kazdego folderu i pliku stosujemy ZELAZNA ZASADE 3xW:
   Weryfikujemy — Zweryfikowane — przez Weryfikacje

8. Prowadz szczegolowy DZIENNIK POKLADOWY:
   Nazwa pliku: TODO_Lista_ASF22_Fendt_Rogator_665.txt
   Zapisuj: co robimy, gdzie robimy, z jakim kodem,
   co poprawilismy, co jest w trakcie, co do ukonczenia,
   co zostalo do zrobienia, co do poprawienia.
   Aktualizuj po kazdej sesji.
   Publikuj na GitHub przed zamknieciem kazdej sesji.

9. Podsumowanie na koncu kazdej sesji

10. NIE rob zmian za mnie — uczysz mnie

11. Odpowiadasz po polsku, kod i Git po angielsku

---

## SRODOWISKO TECHNICZNE

- System: Windows
- Edytor: VS Code z rozszerzeniami (Lua, XML, GitLens, Copilot)
- Terminal: PowerShell (glowne narzedzie)
- Git: skonfigurowany, dziala
- GitHub Desktop: zainstalowany
- GIANTS Editor: zainstalowany

---

## REPO

- URL: https://github.com/asbiofarmer-arch/FS22-Fendt-Rogator-665
- Branch: main
- Lokalizacja: C:\Users\Adam\Documents\GitHub\FS22-Fendt-Rogator-665

---

## STRUKTURA MODA

ASF22_Fendt_Rogator_665/
├── Fendt/
├── GPS/
├── isariaProCompact/
├── Lua/
│ ├── loader.lua
│ ├── ManureSystemVehicle.lua
│ ├── SprayerSectionControl.lua <- AKTYWNY BLAD linia 93
│ └── SprayerSectionControlHUD.lua
├── Models/
│ ├── rogator.i3d
│ ├── rogator.i3d.anim
│ └── rogator.i3d.shapes
├── SDK/
├── Sounds/
├── Specializations/
├── Textures/
├── Translate/
│ ├── l10n_en.xml <- AKTYWNY BLAD missing keys
│ ├── l10n_de.xml
│ └── l10n_fr.xml
├── Vehicles/
│ └── rogator.xml
├── modDesc.xml
├── CLAUDE.md
└── TODO_Lista_ASF22_Fendt_Rogator_665.txt

---

## AKTYWNE BLEDY — PRIORYTET NAPRAWY

### BLAD 1 — l10n Missing (napraw jako PIERWSZY — najprostszy)

- Symptom: Warning: Missing l10n 'input_IC_SPACE' i 4 inne klucze
- Przyczyna: brakujace klucze w plikach Translate/l10n\_\*.xml
- Pliki: Translate/l10n_en.xml, l10n_de.xml, l10n_fr.xml
- Status: DO NAPRAWY

### BLAD 2 — Lua crash linia 93 (sredni)

- Symptom: hasXMLProperty(): Argument 1 wrong type. Expected Int, got Table
- Plik: Lua/SprayerSectionControl.lua linia 93
- Przyczyna: funkcja otrzymuje tabele Lua zamiast uchwytu XML
- Status: DO NAPRAWY

### BLAD 3 — Bledna sciezka dataS (do zbadania)

- Symptom: Error: Can't load resource '.../dataS/scripts/vehicles/Vehicle.lua'
- Przyczyna: mod probuje zaladowac wewnetrzny plik silnika gry
- Status: DO ZBADANIA

---

## CELE PROJEKTU

- Nauka moddingu krok po kroku — wlasny rozwoj
- Uzytek wlasny w grze
- Baza wiedzy do kolejnych modow FS22/FS25
- BRAK planow publikacji na ModHub

---

## HISTORIA SESJI — POSTEP

### Etap 1 — Git/GitHub ZALICZONE

- Repo zalozone i skonfigurowane
- Struktura folderow zatwierdzona
- Pliki wgrane na GitHub

### Etap 2 — Lua/XML dla FS22 <- JESTESMY TUTAJ

- Analiza bledow z log.txt — ZROBIONA
- CLAUDE.md utworzony i wgrany na GitHub — ZROBIONE
- Naprawa Bledu 1 l10n — NASTEPNY KROK
- Naprawa Bledu 2 Lua linia 93 — PLANOWANE
- Zbadanie Bledu 3 dataS — PLANOWANE
- Poprawne kierunki oprysku na bomie — PLANOWANE

---

## JAK ZACZAC NOWA SESJE

1. Wklej zawartosc tego pliku CLAUDE.md jako pierwsza wiadomosc
2. Wklej aktualna zawartosc TODO_Lista_ASF22_Fendt_Rogator_665.txt
3. Napisz nad czym chcesz dzis pracowac
4. Claude ma pelny kontekst — zero powtarzania historii
