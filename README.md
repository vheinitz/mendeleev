# 🧪 Periodensystem Lernprogramm

Eine kindgerechte Flutter-App zum Lernen des Periodensystems der chemischen
Elemente – mit Quiz, Referenz, Molmasse-Rechner und Atommodellen.

## Funktionen

- **Periodensystem (Referenz):** alle 118 Elemente farblich nach Kategorie,
  Antippen zeigt Details inkl. **Bohr'schem Atommodell** (Elektronenschalen).
- **Quiz & Üben:** Gruppe nennen, Symbol ↔ Name, lateinische Namen,
  Lücke im Periodensystem füllen. Clevere, ähnlich aussehende Falschantworten
  und keine Wiederholungen pro Runde.
- **Elemente konfigurieren:** per Tippen in der Tabelle ein-/ausblenden,
  welche Elemente abgefragt werden (Standard: die wichtigsten).
- **Fehler-Statistik:** Problem-Elemente werden mit immer dickerem roten
  Rahmen markiert (ein-/ausschaltbar, zurücksetzbar).
- **Molmasse-Rechner:** über 100 Stoffe aus dem Chemieunterricht mit
  Live-Filter (Name oder Formel) und Zerlegung der Zusammensetzung.

## Voraussetzungen

- Flutter SDK (3.38 oder neuer)
- Android SDK (für APK-Build)
- Git

## Schnellstart

```bash
# 1. Benötigte Werkzeuge herunterladen/installieren (falls nicht vorhanden)
./scripts/setup.sh

# 2. Android-APK (nur arm64, Release) bauen
./scripts/build_apk.sh

# 3. Auf ein angeschlossenes Gerät installieren
./scripts/install_apk.sh
```

Die fertige APK liegt unter `build/app/outputs/flutter-apk/app-release.apk`.

## Entwicklung

```bash
flutter pub get
flutter run          # App starten
flutter test         # Tests ausführen
flutter analyze      # Statische Analyse
```

## Projektstruktur

```
lib/
  data/        Elemente, Stoffe, wichtige Auswahl
  models/      Element-Modell
  services/    Einstellungen, Formel-Parser, Distraktoren, Elektronenschalen
  screens/     Start, Periodensystem, Quiz, Molmasse, Konfiguration
  widgets/     Tabelle, Atommodell-Diagramm, Farben
test/          Unit- und Widget-Tests
scripts/       Setup-, Build- und Installations-Skripte
```
