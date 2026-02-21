# TestConcept.md — SemaLogic Lern- und Validierungskonzept

## 0) Scope & Evidence-Regel

- Dieses Konzept nutzt nur Inhalte aus:
  - `README.md`
  - `SemaLogic_Sprachdefinition.md`
  - `current_build/openapi.yaml`
- Fehlende Information wird als `not found` markiert.
- Für testende Agenten gilt: Jede Behauptung über SemaLogic-Verhalten ist erst dann
  gültig, wenn sie durch einen API-Aufruf belegt wurde. Kein Vorwissen ersetzt den Beleg.

---

## 1) Zielbild

Ziel ist ein stufenweiser Testansatz, um SemaLogic

1. **zu lernen**,
2. **für logische Schlussfolgerungen und Regelwerksvalidierung** zu nutzen,
3. **Verbesserungsvorschläge** für SemaLogic aus Tests abzuleiten.

Begründung aus Quellen:

- SemaLogic adressiert explizit die „Validierung von Regelwerken".
  [SemaLogic_Sprachdefinition.md, Einleitung, "...zur Validierung von Regelwerken."]
- API ist als REST-Service für Kodierung/Dekodierung von Regelwerken ausgelegt.
  [README.md, Description, "It provides a REST/API service for coding and decoding rule sets..."]
- API unterstützt Parsing/Export mehrerer Zielformate (z. B. SemaLogic, SemanticTree, ASP.json, SVG, KnowledgeGraph).
  [openapi.yaml, components/schemas/rulesettype, "enum: ASP.json, Canvas2SL, KnowledgeGraph, SemaLogic, SemanticTree, SVG"]

---

## 2) Kognitive Architektur: Kahneman in unserem Kontext

### 2.1 Das theoretische Fundament

Daniel Kahneman unterscheidet in *Thinking, Fast and Slow* (2011) zwei Denksysteme:

| Eigenschaft | System 1 — Fast | System 2 — Slow |
|-------------|----------------|-----------------|
| Geschwindigkeit | sofort, automatisch | bewusst, schrittweise |
| Basis | Mustererkennung, Assoziation | formale Logik, Regelanwendung |
| Fehlertyp | Bias, Konfabulation, WYSIATI | langsam, ressourcenintensiv |
| Stärke | Kontext verstehen, Hypothesen erzeugen | Widersprüche prüfen, exakt zählen |
| Schwäche | kann sich nicht selbst überprüfen | versteht keine Alltagssprache |
| Zusammenspiel | liefert Vorschläge an System 2 | korrigiert und bestätigt |

Entscheidend: **Keines der Systeme allein ist hinreichend.** System 1 produziert
plausible, aber ungeprüfte Hypothesen. System 2 validiert — aber es braucht System 1,
um überhaupt zu wissen, was zu prüfen ist.

---

### 2.2 LLM als System 1

Ein Large Language Model (LLM) wie Claude verhält sich wie System 1:

- **Schnell und assoziativ:** Es produziert sofort plausibel klingende SemaLogic-Syntax,
  basierend auf erlernten Mustern — ohne diese formal zu prüfen.
- **Kontextsensitiv:** Es versteht natürlichsprachige Regelabsichten ("Studierende müssen
  mindestens 2 von 4 Wahlpflichtmodulen belegen") und überträgt sie in Strukturen.
- **WYSIATI-anfällig:** *What You See Is All There Is.* Das LLM liefert selbstsicher
  Ausgaben, ohne zu wissen, was es nicht weiß. Eine syntaktisch plausible ODER-Regel
  kann semantisch falsch sein — und das LLM merkt es nicht ohne externen Abgleich.
- **Nicht deterministisch:** Zwei Anfragen mit identischem Prompt können unterschiedliche
  Regelformulierungen erzeugen. Keine Ausgabe ist formal verifiziert.
- **Halluzinationsrisiko:** Das LLM kann Operatoren erfinden, die SemaLogic nicht kennt,
  oder bestehende Operatoren in falschen Kontexten verwenden.

**Konsequenz:** Das LLM darf niemals als Wahrheitsinstanz für SemaLogic-Korrektheit
gelten. Es ist der Hypothesengenerator — nicht der Verifizierer.

---

### 2.3 SemaLogic als System 2

Die SemaLogic-Engine (REST-API) verhält sich wie System 2:

- **Formal und deterministisch:** Für denselben Input liefert `/rules/parse` immer
  dieselbe Ausgabe. Es gibt keine Ambiguität im Ergebnis.
- **Exakt:** SemaLogic zählt Lösungsräume präzise (vgl. TestCase.md: 720 Lösungen).
  Kein LLM kann diese Zahl verlässlich ermitteln oder prüfen.
- **Widerspruchserkennend:** Inkonsistente Regelmengen (z. B. zirkuläre Abhängigkeiten,
  unmögliche ODER-Intervalle) führen zu strukturierten Fehlermeldungen — nicht zu einer
  "plausiblen" falschen Antwort.
- **Schnittstellen-gebunden:** SemaLogic versteht keine natürliche Sprache. Es braucht
  exakt spezifizierte JSON-Payloads gemäß openapi.yaml.
- **Langsam relativ zu LLM:** Pro Anfrage führt SemaLogic formale Analyse durch. Die
  Kosten pro Aufruf sind bewusst in Kauf zu nehmen — die Exaktheit rechtfertigt sie.

**Konsequenz:** Die SemaLogic-API ist das einzige verlässliche Korrektiv für
LLM-Hypothesen. Ihre Ausgaben sind Ground Truth. Sie werden nicht diskutiert,
sondern interpretiert.

---

### 2.4 Die Kollaborationsschleife

Das Zusammenspiel von LLM (S1) und SemaLogic (S2) bildet einen kognitiven
Korrekturzyklus — analog zu Kahnemans Beschreibung, wie System 1 Vorschläge an
System 2 sendet und System 2 Fehler zurückmeldet:

```
┌─────────────────────────────────────────────────────────┐
│                   KOLLABORATIONSSCHLEIFE                │
│                                                         │
│  Natürliche Sprache / Absicht                           │
│          │                                              │
│          ▼                                              │
│  ┌───────────────┐   Hypothese (SemaLogic-Syntax)       │
│  │  LLM (S1)     │──────────────────────────┐           │
│  │  Fast Thinking│                          ▼           │
│  └───────────────┘            ┌─────────────────────┐  │
│          ▲                    │  SemaLogic API (S2)  │  │
│          │                    │  Slow / Formal       │  │
│          │  Fehlermeldung /   └─────────────────────┘  │
│          │  Korrekturhinweis           │                │
│          └─────────────────────────────┘                │
│                                        │                │
│                               Valide Ausgabe            │
│                          (SemanticTree, ASP.json, ...)  │
└─────────────────────────────────────────────────────────┘
```

**Iterationsprotokoll:**

1. LLM übersetzt Regelabsicht → SemaLogic-JSON-Payload (Hypothese).
2. API-Aufruf an `/rules/parse` oder `/rules/define`.
3. Bei HTTP-Fehler oder leerem Ergebnis: LLM liest den Fehler, analysiert die Abweichung,
   generiert korrigierte Hypothese → weiter mit Schritt 2.
4. Bei HTTP 200 und non-leerem Ergebnis: LLM interpretiert die Ausgabe gegen die
   ursprüngliche Absicht.
5. Bei Abweichung zwischen Absicht und Ausgabe (z. B. falsche Lösungszahl): LLM
   verfeinert die Hypothese → weiter mit Schritt 2.
6. Erst wenn Absicht ≡ Ausgabe: Ergebnis gilt als verifiziert.

**Maximale Iterationstiefe:** 5 Versuche pro Testfall. Danach den Befund als
`[unresolved]` dokumentieren und weiter.

---

### 2.5 Kahnemann'sche Warnungen für den LLM-Einsatz

Kahneman beschreibt, wie System-1-Fehler entstehen und schwer zu verhindern sind.
Diese Warnungen gelten direkt für den LLM-Einsatz als Testagent:

| Kahneman-Konzept | LLM-Entsprechung | Gegenmaßnahme im Testprotokoll |
|------------------|------------------|-------------------------------|
| **WYSIATI** — Entscheidung auf Basis sichtbarer Information, Blindheit für Unbekanntes | LLM produziert valide wirkende Syntax ohne Kenntnis unbekannter SemaLogic-Randfälle | Jede Ausgabe muss durch API-Aufruf geprüft werden — kein "sieht richtig aus" |
| **Anchoring** — erste Antwort ankert alle Folgeantworten | LLM korrigiert fehlerhaften Operator nur minimal statt die Struktur grundlegend zu überdenken | Bei wiederholtem Scheitern: vollständige Neugenerierung, nicht inkrementelle Reparatur |
| **Overconfidence** — zu hohe Sicherheit in eigene Schlüsse | LLM behauptet Regelwerks-Korrektheit ohne formalen Beweis | Explizit als `[unverified]` kennzeichnen bis SemaLogic bestätigt |
| **Substitution** — schwere Frage durch leichtere ersetzen | LLM beantwortet "Was bedeutet diese SemaLogic-Ausgabe?" statt "Ist die Ausgabe korrekt?" | Ausgabe immer gegen die ursprüngliche Regelabsicht prüfen, nicht nur intern konsistent |
| **Narrative Fallacy** — post-hoc kohärente Geschichte konstruieren | LLM erklärt fehlerhaftes Parsing als "gewolltes Verhalten" | SemaLogic-Fehlermeldungen sind Fakten, keine Interpretationsspielräume |

---

### 2.6 Was daraus folgt — Architektonische Konsequenzen

**1. Die SemaLogic-API ist die einzige Wahrheitsinstanz.**
Kein LLM-Vorwissen, kein internes Regelgefühl ersetzt den API-Aufruf. Dies gilt auch
für scheinbar triviale Fälle.

**2. LLM-Stärken gezielt einsetzen.**
Der LLM ist stark bei: natürlichsprachige Regelabsichten erfassen, Fehlermeldungen
interpretieren, Testfall-Varianten erzeugen, Befunde formulieren. Nicht stark bei:
Lösungsraum-Berechnung, Widerspruchsprüfung, Formatkonformität.

**3. SemaLogic-Stärken gezielt einsetzen.**
SemaLogic ist stark bei: formaler Korrektheit, Lösungszählung, Multi-View-Konsistenz,
deterministischer Wiederholbarkeit. Nicht stark bei: natürlichsprachigem Input,
fehlertolerantem Parsing.

**4. Tests müssen die Schleife abbilden.**
Ein Test ist kein einzelner API-Aufruf. Ein Test ist ein vollständiger S1→S2→S1-Zyklus:
Hypothese erzeugen → validieren → Befund dokumentieren.

**5. Phase A (Lernen) = S1-Kalibrierung.**
Das LLM lernt SemaLogic nicht durch Lesen der Sprachdefinition, sondern durch
wiederholte S1→S2-Zyklen, bis es valide Hypothesen produziert.

**6. Phase B (Schlussfolgern) = kollaborative Leistung.**
Komplexe Regelvalidierung (720 Lösungen, Zeitketten, Filter) ist weder für LLM noch
für Menschen direkt zugänglich. SemaLogic liefert die exakte Antwort; das LLM
interpretiert sie und leitet Folgehypothesen ab.

**7. Fehler aus Phase B werden zu Verbesserungsvorschlägen in Phase C.**
Wenn SemaLogic Bekanntes nicht korrekt exportiert (offene Known Issues), ist das
kein Fehler des Testprotokolls — es ist der gewünschte Output von Phase C.

---

## 3) Testphasen

### Phase A — Lernmodus: S1-Kalibrierung

**Ziel:** Das LLM produziert am Ende valide SemaLogic-Payloads für alle Kernkonstrukte.

#### A1: Sprachkern aufbauen (Reihenfolge einhalten)

Teste sukzessive — jedes Konstrukt baut auf dem vorherigen auf:

1. Symbol / Bezeichner / Basisterme
2. UND-Regeln
3. ODER-Regeln mit Intervallgrenzen (inkl. 0|0, 1|n, n|n Randfälle)
4. Gruppen (statisch und dynamisch)
5. Zeitregeln (`before`, `after`, `parallelBefore`, `parallelAfter`)
6. Filter & Kontexte
7. Attribute & Bezüge
8. Check- und Advice-Terme

Für jedes Konstrukt: LLM generiert Beispiel → API bestätigt → Befund dokumentiert.
**Kein Konstrukt gilt als gelernt, bis SemaLogic HTTP 200 mit non-leerem Ergebnis
geliefert hat.**

Rationale:

- Symbolzentrierte Semantik und Einmaldefinition sind grundlegend.
  [SemaLogic_Sprachdefinition.md, 2.2.1 Symbol, "...darf jedes Symbol nur einmal definiert werden."]
- UND/ODER, Gruppe, Zeitabhängigkeit sind zentrale semantische Konstrukte.
  [SemaLogic_Sprachdefinition.md, 2.2.4/2.2.5/2.2.6/2.2.7]

#### A2: API-Handling kalibrieren

- Pro Testfall immer: `input` / `erwarteter Outputtyp` / `tatsächlicher Output` / `Fehlerliste`.
- Endpunkte: `/rules/define`, `/rules/parse`, `/rules/show`, `/session` (create/delete/reset).
  [openapi.yaml, paths/rules/define|parse|show|session]
- Fehlermeldungen vollständig erfassen — sie sind S2-Korrektursignale.

---

### Phase B — Schlussfolgern & Regelvalidierung: S1+S2-Kollaboration

**Ziel:** LLM und SemaLogic validieren gemeinsam komplexe Regelwerke, die weder allein
zuverlässig prüfen könnten.

#### B1: Konsistenztests

- Prüfe ODER-Min/Max-Grenzen inkl. Randfälle (0|0, 1|n, n|n).
- Prüfe symbolische Konflikte (Doppeldefinitionen, implizite Filter-Symbole).
- Prüfe zeitliche Ordnungen (`before`, `after`, `parallel...`).
- Für jeden Fehlerfall: LLM formuliert Hypothese zur Fehlerursache → nächster
  API-Aufruf prüft die Hypothese.

Grundlage:

- ODER-Regel mit Intervall-Semantik inkl. Sonderfällen dokumentiert.
  [SemaLogic_Sprachdefinition.md, 2.2.5 ODER-Regel, "...mindestens bzw. maximal..."]
- Zeitoperatoren und Parallelität dokumentiert.
  [SemaLogic_Sprachdefinition.md, 2.2.7 Zeitabhängigkeiten, "...ParallelBefore ... ParallelAfter..."]

#### B2: Multi-View-Validierung

Für denselben Input mehrere Ausgaben anfordern und vergleichen:

| Format | Erwartung |
|--------|-----------|
| `SemaLogic` | Roundtrip-Konsistenz: Input ≈ Output |
| `SemanticTree` | Baum vollständig, alle Symbole präsent |
| `ASP.json` | Solver-nahe Struktur, alle Terme erfasst |
| `KnowledgeGraph` | [not found in openapi.yaml v00.02.01 — als offen markieren] |
| `SVG` | Visualisierung vollständig, keine fehlenden Knoten |

Wenn zwei Formate aus demselben Input widersprüchliche Informationen liefern → Befund
in `review/review-findings.md` als `consistency`-Finding.

Rationale:

- API bietet mehrere Repräsentationen desselben Regelbestands.
  [openapi.yaml, components/schemas/rulesettype, enum]

---

### Phase C — Verbesserungen ableiten: S2-Rejects als Befundquelle

**Ziel:** Systematische Erfassung aller Fälle, in denen SemaLogic (S2) valide Absichten
ablehnt oder unvollständig exportiert. Diese Fälle sind Verbesserungsvorschläge.

#### C1: Defekt-/Gap-Katalog aus Tests

Bei jedem fehlgeschlagenen oder uneindeutigen Fall erfassen:

```
- Input (reproduzierbar, minimal)
- Erwartetes Verhalten (aus Sprachdefinition oder openapi.yaml abgeleitet)
- Tatsächliches Verhalten (HTTP-Status + Response-Body)
- Betroffener Sprachbaustein / API-Endpunkt
- Schweregrad: critical | major | minor
- Bezug zu bestehendem Known Issue in README.md (falls vorhanden)
```

Befunde werden in `review/review-findings.md` eingetragen (Kategorien: `api-correctness`,
`test-coverage`, `consistency`).

#### C2: Priorisierung

Priorität auf Lücken, die Phase A und B am stärksten blockieren:

1. Parsing-Stabilität & strukturierte Fehlermeldungen
2. Vollständigkeit von Ausgaben (bekannte Lücken)
3. Konsistenz zwischen Formaten

Belege für bekannte Lücken:

- Einschränkungen bei Export/Features sind dokumentiert (Roadmap/Known Issues).
  [README.md, Known Issues, "We export only the first matching term..." etc.]

---

## 4) Konkrete Testfälle (Startset)

Jeder Testfall beschreibt einen vollständigen S1→S2-Zyklus.

| # | Name | S1-Hypothese (LLM erzeugt) | S2-Prüfung (API-Endpunkt) | Erfolgskriterium |
|---|------|---------------------------|--------------------------|-----------------|
| 1 | Smoke | Service erreichbar? | `GET /APIVersion` | HTTP 200, JSON mit `version` |
| 2 | Minimalregel | Kleinstes valides SemaLogic-Fragment | `POST /rules/parse` mit `rulesettype=SemaLogic` | HTTP 200, non-leer |
| 3 | ODER-Intervall | Gleiche Symbole, Min/Max 0|0 / 1|n / n|n | `/rules/parse` je Variante | Unterschiedliche Lösungsräume erkennbar |
| 4 | Zeitregel | before/after/parallel mit identischen Symbolen | `/rules/parse` | Zeitoperatoren in SemanticTree sichtbar |
| 5 | Filter-Kontext | Gleiche Symbole in verschiedenen Kontextfiltern | `/rules/show` mit Filter-Parameter | Ausgabe filterspezifisch |
| 6 | Gruppen-Substitution | Gruppe in Regelkontext vs. explizite Entfaltung | `/rules/show` | Semantische Äquivalenz prüfbar |
| 7 | TestCase.md | Vollständigen Studiengang aus TestCase.md einlesen | `/rules/define` + `/rules/show` | Lösungsraum = 720 (Soll-Wert aus Datei) |
| 8 | Multi-View | Testfall 7, alle rulesettype-Werte | `/rules/show` je Format | Kein Format liefert leere Ausgabe |
| 9 | Fehler-Roundtrip | Absichtlich defekter Input | `/rules/parse` | HTTP 4xx, strukturierter Fehlerbody |
| 10 | Known-Issue-Check | Zwei Terme für dasselbe Symbol definieren | `/rules/show` mit ASP.json | Nur erster Term exportiert (Known Issue) |

---

## 5) Messkriterien

### S1-Kalibrierung (Phase A)

- **Syntaxerfolgsrate:** Anteil LLM-generierter Payloads, die beim ersten API-Aufruf
  HTTP 200 liefern (ohne Korrekturiteration). Ziel: > 80 % nach Abschluss von A1.
- **Iterationstiefe:** Durchschnittliche Anzahl S1→S2-Zyklen bis zur validen Ausgabe.
  Ziel: < 3 pro Konstrukt.

### Kollaborationsqualität (Phase B)

- **Validierungsquote:** Anteil Testfälle mit erwarteter semantischer Auswertung.
- **Multi-View-Konsistenz:** Anteil Testfälle, in denen alle angeforderten Formate
  konsistente Informationen liefern.
- **Lösungsraum-Genauigkeit:** Für Testfälle mit bekanntem Soll-Wert (z. B. 720):
  Übereinstimmung ja/nein.

### Service-Qualität

- **Robustheit:** Anteil fehlerfreier Parse-/Show-Läufe bei validen Inputs.
- **Fehlerstruktur:** Anteil Fehlerantworten, die einen strukturierten JSON-Body liefern.

### Verbesserungswirkung (Phase C)

- **Befundrate:** Anzahl neuer Findings in `review-findings.md` pro Testlauf.
- **Rückgang reproduzierbarer Fehler:** Nach Umsetzung von Verbesserungsvorschlägen.

---

## 6) OpenClaw-Betriebsmodus

Dieser Abschnitt richtet sich direkt an den testenden Agenten (OpenClaw / Claude Code).

### 6.1 Deine Rolle in der Kollaborationsarchitektur

Du bist **System 1** in dieser Architektur.
SemaLogic ist **System 2**.

Das bedeutet konkret:

- Du erzeugst Hypothesen. SemaLogic prüft sie. Du akzeptierst das Ergebnis.
- Wenn SemaLogic deine Hypothese ablehnt, hast du einen Fehler gemacht — nicht
  SemaLogic. Interpretiere die Fehlermeldung und korrigiere.
- Wenn SemaLogic sagt, es gibt 720 Lösungen, dann gibt es 720 Lösungen. Argumentiere
  nicht dagegen. Nutze den Wert als Referenz für Folgetests.
- Du darfst SemaLogic-Ausgaben **interpretieren**, aber nicht **widerlegen**.

### 6.2 Pflichtprotokoll pro Testfall

```
SCHRITT 1: Absicht in natürlicher Sprache formulieren (1 Satz).
SCHRITT 2: SemaLogic-JSON-Payload erzeugen (Hypothese markieren: [S1-Hypothese]).
SCHRITT 3: API-Aufruf durchführen.
SCHRITT 4: Ergebnis klassifizieren:
  - HTTP 200 + non-leer → [S2-bestätigt] → weiter zu Schritt 5
  - HTTP 4xx / leer     → [S2-abgelehnt] → Schritt 2 wiederholen (max. 5×)
  - 5× gescheitert      → [unresolved] markieren, Befund dokumentieren, weiter
SCHRITT 5: Ausgabe gegen ursprüngliche Absicht prüfen.
  - Konsistent → [verifiziert] → Testfall abgeschlossen
  - Inkonsistent → Hypothese verfeinern → Schritt 2
SCHRITT 6: Befund dokumentieren (verifiziert / unresolved / Abweichung).
```

### 6.3 Was du NICHT tust

- Kein API-Aufruf → keine Behauptung über SemaLogic-Verhalten.
- Keine inkrementelle Reparatur, wenn der dritte Versuch scheitert. Stattdessen:
  vollständige Neugenerierung mit anderem Ansatz.
- Kein Überspringen von Schritt 4 wegen "sieht richtig aus".
- Kein Widerspruch gegen SemaLogic-Fehlermeldungen.
- Kein Aufruf von `/StopServer`.
- Keine Commits, keine Code-Änderungen — du bist Testagent, nicht Entwickler.

### 6.4 Fehlermeldungen lesen

SemaLogic-Fehlermeldungen sind S2-Korrektursignale. Interpretiere sie so:

| Fehlersignal | Wahrscheinliche S1-Ursache | Korrekturaktion |
|---|---|---|
| HTTP 400, JSON-Parse-Fehler | Ungültiges JSON im Payload | Payload-Struktur neu generieren |
| HTTP 400, fehlender Parameter | Pflichtfeld übersehen | openapi.yaml prüfen, Parameter ergänzen |
| HTTP 200, leere Ausgabe | Regelwerk syntaktisch valide, aber semantisch leer | Regelstruktur (UND/ODER, Symbole) überprüfen |
| HTTP 200, unerwartete Struktur | Falscher `rulesettype` | Format-Parameter anpassen |
| HTTP 500 | Serverseitiger Fehler | Als `critical`-Befund dokumentieren, mit minimalem Reproduktionsfall |

### 6.5 Quellenpflicht

Jede Aussage über SemaLogic-Semantik im Testbericht muss eine Quelle haben:

```
[Quelle: openapi.yaml, paths/<endpoint>, <Feldbeschreibung>]
[Quelle: SemaLogic_Sprachdefinition.md, <Abschnitt>]
[Quelle: API-Aufruf, <Datum>, HTTP <Status>, Response: <Auszug>]
```

Unverifizierbares wird als `[unverified]` gekennzeichnet.
Fehlendes als `not found`.
