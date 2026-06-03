# Dachgeschossflächen

Ein eigenständiger Wohnflächenrechner für ausgebaute Dachgeschosse. Die gesamte
Anwendung steckt in einer einzigen HTML-Datei (`dachgeschoss_calculator.html`) – ohne
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

- **Wohnflächenberechnung** nach Höhenanteilen, mit prozentualem Abschlag für
  Wände.
- **Innenmaß-Berechnung**: Aus den Außenmaßen wird über die Wandstärke automatisch
  die nutzbare Grundfläche abgeleitet (Außenmaß − 2 × Wandstärke je Achse).
- **Beliebig viele Schleppgauben**: dynamische Liste mit Hinzufügen/Entfernen,
  Seitenwahl (links/rechts) und Positionierung über Start-/Endabstand. Jede Gaube
  wird nach ihrer tatsächlichen lichten Höhe angerechnet (siehe unten).
- **Beliebig viele Freiflächen** (z. B. Loggia, Treppenhaus): dynamische,
  benannte Liste. Jede Fläche wird über eine Lage (links/mitte/rechts und
  oben/mitte/unten) sowie Länge und Breite definiert und aus allen Flächen
  herausgerechnet.
- **Vollgeschoss-Prüfung**: prüft live, ob die Fläche mit ≥ 2,2 m lichter Höhe
  mehr als zwei Drittel der Hausgrundfläche einnimmt (Ampel grün/rot).
- **Zeichnungen**: maßstäbliche Querschnitt- und Draufsicht-Darstellung mit
  Höhenbändern, Außenwänden, Gauben und Freiflächen.
- **Diagramm „Fläche/Kniestock“**: bereinigte Wohnfläche in Abhängigkeit von
  Dachneigung und Kniestockhöhe.
- **Speichern / Laden** der kompletten Konfiguration als JSON-Datei.

## Bedienung

Die Datei `dachgeschoss_calculator.html` im Browser öffnen. Alle Eingaben wirken sofort auf
Tabellen, Zeichnungen und das Diagramm.

### Eingaben

Die linke Spalte ist in drei Reiter unterteilt:

**Basis**

- **Länge / Breite** – Außenmaße des Gebäudes.
- **Dicke Außenwände** – wird beidseitig von Länge und Breite abgezogen.
- **Kniestock** – Höhe der Drempelwand (0–1 m).
- **Dachneigung** – Dachschräge in Grad (mindestens 25°).
- **Abschlag Wände** – prozentualer Abschlag auf die anrechenbare Fläche.

**Gauben**

Liste von Schleppgauben. Pro Gaube:

- **Seite** – links oder rechts (Umschalter).
- **Tiefe** – wie weit die Gaube ins Gebäude reicht. Sie bestimmt zugleich die
  lichte Höhe der Gaube (siehe Berechnungsmodell).
- **Start / Ende ab Ecke** – Position entlang der Länge, gemessen von der
  **oberen Hausecke**. Die Breite der Gaube ergibt sich aus Ende − Start.

**Freiflächen**

Liste abzuziehender Flächen (z. B. Loggia, Treppenhaus). Pro Fläche:

- **Name** – frei wählbar.
- **Lage** – horizontal (links/mitte/rechts) und vertikal (oben/mitte/unten).
- **Länge / Breite** – Abmessungen der Fläche.

Die horizontale Lage entscheidet, in welchen Höhenbändern die Fläche liegt und
damit, wie viel anrechenbare Fläche sie entfernt; die vertikale Lage ist rein
für die Darstellung.

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
  "version": 2,
  "laenge": 20,
  "breite": 10,
  "dicke": 0.35,
  "kniestock": 0,
  "slope": 45,
  "penalty_walls": 0,
  "gauben": [
    { "side": "left",  "tiefe": 3, "start": 5, "ende": 15 },
    { "side": "right", "tiefe": 3, "start": 2, "ende": 6 }
  ],
  "freiflaechen": [
    { "name": "Loggia",      "hpos": "links",  "vpos": "oben",  "laenge": 4,   "breite": 4 },
    { "name": "Treppenhaus", "hpos": "rechts", "vpos": "mitte", "laenge": 2.6, "breite": 5 }
  ]
}
```

## Berechnungsmodell und Annahmen

- Sämtliche Flächenberechnungen laufen auf dem **Innenmaß** (Außenmaß abzüglich
  Wandstärke). Als Bezug für die Vollgeschoss-Prüfung dient hingegen die
  **Hausgrundfläche** (äußeres Länge × Breite).
- Eine Schleppgaube wird als Schleppdach mit flacher Decke modelliert. Ihre
  lichte Höhe ist `H = Kniestock + Tiefe × tan(Dachneigung)` – die Höhe, in der
  sie auf das Hauptdach trifft. Die gesamte Gaubenfläche wird nach dieser Höhe H
  angerechnet:
  - H ≥ 2 m → volle Anrechnung (grün),
  - 1 m ≤ H < 2 m → halbe Anrechnung (gelb),
  - H < 1 m → keine Anrechnung (rot).
  Nur ab H ≥ 2,2 m zählt die Gaube zur Vollgeschoss-Fläche. Eine flache, niedrige
  Gaube erhöht also weder die volle Fläche noch das Vollgeschoss. Die Tiefe ist
  auf die halbe Gebäudebreite begrenzt, damit die Gaube auf ihrer Dachseite
  bleibt.
- Eine Freifläche entfernt ihre Grundfläche aus genau den Höhenbändern, die sie
  – abhängig von ihrer horizontalen Lage – überdeckt.
- **Überlappungen werden nicht aufgelöst.** Liegen zwei Gauben derselben Seite
  oder zwei Flächen auf derselben Grundfläche, addieren sich ihre Effekte. Die
  Standardwerte sind überschneidungsfrei gewählt.
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
