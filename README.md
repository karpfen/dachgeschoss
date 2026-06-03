# Dachgeschossflächen

Ein eigenständiger Wohnflächenrechner für ausgebaute Dachgeschosse. Die gesamte
Anwendung steckt in einer einzigen HTML-Datei (`dachgeschoss.html`) – ohne
externe Abhängigkeiten, ohne Server, ohne Internetverbindung. Einfach im Browser
öffnen.

Die Anrechnung der Flächen folgt der Logik der Wohnflächenverordnung: Flächen
unter Dachschrägen zählen je nach lichter Höhe anteilig.

| Lichte Höhe        | Anrechnung |
|--------------------|-----------:|
| unter 1 m          |       0 %  |
| 1 m bis unter 2 m  |      50 %  |
| ab 2 m             |     100 %  |

## Funktionen

- **Wohnflächenberechnung** nach Höhenanteilen, inklusive Abzügen für Wände und
  sonstige Flächen (z. B. Treppenhaus).
- **Innenmaß-Berechnung**: Aus den Außenmaßen wird über die Wandstärke automatisch
  die nutzbare Grundfläche abgeleitet (Außenmaß − 2 × Wandstärke je Achse).
- **Beliebig viele Schleppgauben**: dynamische Liste mit Hinzufügen/Entfernen,
  Seitenwahl (links/rechts) und Positionierung über Start-/Endabstand.
- **Loggia**: ein Rücksprung in der oberen linken Ecke, dessen Fläche aus allen
  Berechnungen herausgerechnet wird.
- **Vollgeschoss-Prüfung**: prüft live, ob die Fläche mit ≥ 2,2 m lichter Höhe
  mehr als zwei Drittel der Hausgrundfläche einnimmt (Ampel grün/rot).
- **Zeichnungen**: maßstäbliche Querschnitt- und Draufsicht-Darstellung mit
  Höhenbändern, Außenwänden, Gauben und Loggia.
- **Diagramm „Fläche/Kniestock“**: bereinigte Wohnfläche in Abhängigkeit von
  Dachneigung und Kniestockhöhe.
- **Speichern / Laden** der kompletten Konfiguration als JSON-Datei.

## Bedienung

Die Datei `dachgeschoss.html` im Browser öffnen. Alle Eingaben wirken sofort auf
Tabellen, Zeichnungen und das Diagramm.

### Eingaben

Die linke Spalte ist in zwei Reiter unterteilt:

**Basis**

- **Länge / Breite** – Außenmaße des Gebäudes.
- **Dicke Außenwände** – wird beidseitig von Länge und Breite abgezogen.
- **Kniestock** – Höhe der Drempelwand (0–1 m).
- **Dachneigung** – Dachschräge in Grad (mindestens 25°).
- **Abschlag Wände** – prozentualer Abschlag auf die anrechenbare Fläche.
- **Sonstige Abschläge** – fester Flächenabzug in m² (z. B. Treppenhaus).

**Gauben + Loggia**

- Pro **Schleppgaube**: Tiefe (wie weit ins Gebäude), Start- und Endabstand
  entlang der Länge sowie ein Schalter für die Seite (links/rechts). Innerhalb
  ihrer Grundfläche wird die lichte Höhe auf volle Anrechnung angehoben.
  Start/Ende werden von der **oberen Hausecke** aus gemessen.
- **Loggia**: Länge und Breite des Rücksprungs in der oberen linken Ecke.

### Ergebnisse (Kopfzeile)

- **Längen** – Dachhöhe (Firsthöhe) und die Abseitentiefen bei 1 m und 2 m.
- **Flächen** – Flächen der Höhenbänder, Gesamtfläche und die bereinigte
  Wohnfläche.
- **Vollgeschoss-Prüfung** – Fläche ≥ 2,2 m, ihr Anteil an der Hausgrundfläche
  und die Zwei-Drittel-Grenze.

### Speichern / Laden

Über die Schaltflächen am unteren Rand der Eingabespalte lässt sich die aktuelle
Konfiguration als JSON exportieren (`dachgeschoss-konfiguration.json`) und später
wieder einlesen.

```json
{
  "version": 1,
  "laenge": 20,
  "breite": 10,
  "dicke": 0.35,
  "kniestock": 0,
  "slope": 45,
  "loggia_laenge": 4,
  "loggia_breite": 4,
  "penalty_walls": 0,
  "penalty_other": 13,
  "gauben": [
    { "side": "left",  "tiefe": 3, "start": 5,  "ende": 15 },
    { "side": "right", "tiefe": 3, "start": 5,  "ende": 9 }
  ]
}
```

## Berechnungsmodell und Annahmen

- Sämtliche Flächenberechnungen laufen auf dem **Innenmaß** (Außenmaß abzüglich
  Wandstärke). Als Bezug für die Vollgeschoss-Prüfung dient hingegen die
  **Hausgrundfläche** (äußeres Länge × Breite).
- Eine Schleppgaube hebt ihre Grundfläche auf volle lichte Höhe an; ohne
  zusätzliche Höhen-/Neigungsangabe wird sie als voll nutzbar angenommen. Die
  Tiefe wird auf die halbe Gebäudebreite begrenzt, damit die Gaube auf ihrer
  Dachseite bleibt.
- Die Loggia entfernt ihre Grundfläche vollständig aus allen Bändern.
- **Überlappungen werden nicht aufgelöst.** Liegen zwei Gauben derselben Seite
  oder eine Gaube und die Loggia auf derselben Grundfläche, addieren sich ihre
  Effekte. Die Standardwerte sind überschneidungsfrei gewählt.
- Die Vollgeschoss-Regel ist je nach Landesbauordnung unterschiedlich
  (z. B. zwei Drittel vs. drei Viertel, 2,2 m vs. 2,3 m). Hier sind zwei Drittel
  und 2,2 m hinterlegt. Im Zweifel die jeweils gültige LBO prüfen.

Dieses Werkzeug dient der Orientierung und ersetzt keine rechtsverbindliche
Wohnflächen- oder Vollgeschossberechnung.

## Technik

- Eine einzige HTML-Datei, reines HTML/CSS/JavaScript, keine Build-Schritte,
  keine externen Bibliotheken oder Schriftarten.
- Zeichnungen und Diagramm werden als Inline-SVG gerendert.
- Funktioniert vollständig offline (auch direkt von der Festplatte geöffnet).

## Lizenz

MIT-Lizenz. © 2026 Andreas Petutschnig · andreas@petutschnig.de