# TestConcept.md — SemaLogic Lern- und Validierungskonzept

## 0) Scope & Evidence-Regel
- Dieses Konzept nutzt nur Inhalte aus:
  - `README.md`
  - `SemaLogic_Sprachdefinition.md`
  - `current_build/openapi.yaml`
- Fehlende Information wird als `not found` markiert.

---

## 1) Zielbild
Ziel ist ein stufenweiser Testansatz, um SemaLogic
1. **zu lernen**,
2. **für logische Schlussfolgerungen und Regelwerksvalidierung** zu nutzen,
3. **Verbesserungsvorschläge** für SemaLogic aus Tests abzuleiten.

Begründung aus Quellen:
- SemaLogic adressiert explizit die „Validierung von Regelwerken“.  
  [SemaLogic_Sprachdefinition.md, Einleitung, "...zur Validierung von Regelwerken."]
- API ist als REST-Service für Kodierung/Dekodierung von Regelwerken ausgelegt.  
  [README.md, Description, "It provides a REST/API service for coding and decoding rule sets..."]
- API unterstützt Parsing/Export mehrerer Zielformate (z. B. SemaLogic, SemanticTree, ASP.json, SVG, KnowledgeGraph).  
  [openapi.yaml, components/schemas/rulesettype, "enum: ASP.json, Canvas2SL, KnowledgeGraph, SemaLogic, SemanticTree, SVG"]

---

## 2) Slow/Fast-Thinking-Orientierung (Kahneman-inspiriert)
Hinweis: Die Begriffe „System 1 / System 2“ sind **nicht** in den bereitgestellten SemaLogic-Dokumenten enthalten → `not found`.

### Fast-Lane (schnelle Plausibilisierung)
Ziel: schnelle, häufige Checks mit geringer Tiefe.
- Service-Liveness + Version prüfen (`/` oder `/APIVersion`).  
  [openapi.yaml, paths/, "Generate a simple reply... service is running"]  
  [openapi.yaml, paths/APIVersion, "Show the current API-Version"]
- Kurze Parse-Runden mit kleinem Regelinput über `/rules/parse`.
- Primär `rulesettype=SemaLogic` oder `SemanticTree` für schnelle Sichtbarkeit.

### Slow-Lane (tiefe, formale Prüfung)
Ziel: semantische und logische Validierung mit Sessions, Filtern, Regeln, Zeitbezügen.
- Session-basiertes Arbeiten (`sid`) für reproduzierbare Testläufe.  
  [openapi.yaml, components/parameters/sid, "Session identifier (sid) ..."]
- Persistente Definitionen + gezielte Exporte (`/rules/define`, `/rules/show`, `/rules/parse`).
- Gezielte Tests für ODER-Intervalllogik, Gruppen/Substitution, Zeitabhängigkeiten, Filterkontexte.

---

## 3) Testphasen

## Phase A — Lernmodus (A)
### A1: Sprachkern aufbauen
Teste sukzessive:
1. Symbol/Bezeichner/Basisterme
2. UND/ODER-Regeln
3. Gruppen (inkl. dynamische Gruppe)
4. Zeitregeln
5. Filter & Kontext
6. Attribute/Bezüge

Rationale:
- Symbolzentrierte Semantik und Einmaldefinition sind grundlegend.  
  [SemaLogic_Sprachdefinition.md, 2.2.1 Symbol, "...darf jedes Symbol nur einmal definiert werden."]
- UND/ODER, Gruppe, Zeitabhängigkeit sind zentrale semantische Konstrukte.  
  [SemaLogic_Sprachdefinition.md, 2.2.4/2.2.5/2.2.6/2.2.7]

### A2: API-Handling lernen
- Pro Testfall immer: input, erwarteter Outputtyp, tatsächlicher Output, Fehlerliste.
- Endpunkte: `/rules/define`, `/rules/parse`, `/rules/show`, `/reset`, optional `/session` cleanup.  
  [openapi.yaml, paths/rules/define|parse|show|reset|session]

## Phase B — Schlussfolgern & Regelvalidierung (B)
### B1: Konsistenztests
- Prüfe ODER-Min/Max-Grenzen inkl. Randfälle (0|0, 1|n, n|n).
- Prüfe symbolische Konflikte (Doppeldefinitionen, implizite Filter-Symbole).
- Prüfe zeitliche Ordnungen (`before`, `after`, `parallel...`).

Grundlage:
- ODER-Regel mit Intervall-Semantik inkl. Sonderfällen dokumentiert.  
  [SemaLogic_Sprachdefinition.md, 2.2.5 ODER-Regel, "...mindestens bzw. maximal..." ]
- Zeitoperatoren und Parallelität dokumentiert.  
  [SemaLogic_Sprachdefinition.md, 2.2.7 Zeitabhängigkeiten, "...ParallelBefore ... ParallelAfter..."]

### B2: Multi-View-Validierung
Für denselben Input mehrere Ausgaben vergleichen:
- `SemaLogic` (Text)
- `SemanticTree` (ASCII)
- `ASP.json` (Solver-nahe Struktur)
- optional `KnowledgeGraph`/`SVG`

Rationale:
- API bietet mehrere Repräsentationen desselben Regelbestands.  
  [openapi.yaml, components/schemas/rulesettype, enum]

## Phase C — Verbesserungen für SemaLogic ableiten (C)
### C1: Defekt-/Gap-Katalog aus Tests
Bei jedem fehlgeschlagenen oder uneindeutigen Fall erfassen:
- reproduzierbarer Input
- erwartetes vs. tatsächliches Verhalten
- betroffener Sprachbaustein/API-Endpunkt
- Schweregrad

### C2: Vorschläge priorisieren
Priorität auf Lücken, die A/B am stärksten verbessern:
1. Parsing-Stabilität & Fehlermeldungen
2. Vollständigkeit von Ausgaben (bekannte Lücken)
3. Konsistenz zwischen Formaten

Belege für bekannte Lücken:
- Einschränkungen bei Export/Features sind dokumentiert (Roadmap/Known Issues).  
  [README.md, Known Issues, "We export only the first matching term..." etc.]

---

## 4) Konkrete Testfälle (Startset)
1. **Smoke Test**: `/APIVersion`, `/` → Service erreichbar.
2. **Minimalregel**: kleiner SemaLogic-Input über `/rules/parse` mit `rulesettype=SemaLogic`.
3. **ODER-Intervall**: gleiche Symbolmenge mit mehreren Min/Max-Konfigurationen.
4. **Zeitregel**: before/after/parallel Varianten mit identischen Symbolen.
5. **Filter-Kontext**: gleiche Symbole in verschiedenen Kontextfiltern.
6. **Gruppen-Substitution**: Gruppe in Regelkontexten gegen explizite Entfaltung vergleichen.

---

## 5) Messkriterien
- **Lernfortschritt**: Anteil erfolgreich modellierter Sprachkonstrukte pro Phase.
- **Validierungsqualität**: Anteil Testfälle mit erwarteter semantischer Auswertung.
- **Service-Robustheit**: Anteil fehlerfreier Parse-/Show-Läufe.
- **Verbesserungswirkung**: Rückgang reproduzierbarer Fehler nach Vorschlagsumsetzung.

---

## 6) Betriebsmodus für die weitere Zusammenarbeit
- Jede fachliche Aussage zu SemaLogic wird mit Quelle+Zitat belegt.
- Unklare Punkte werden als `[unverified]` markiert.
- Wenn nicht explizit in den drei Quellen enthalten: `not found`.
