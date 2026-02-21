# Review — Process and Interface

This directory is the single point of exchange between the AI reviewer (Claude Code)
and the development team. Everything the reviewer produces lands here. Everything the
team needs to act on or track is readable here.

The review process is an alternative to (or complement of) GitHub issues: findings that
are too detailed, too exploratory, or too interconnected for a single issue belong here.

---

## Files

| File | Role |
|------|------|
| `review-findings.md` | Accumulative finding list — the data bridge (see below) |
| `REVIEW.md` | This file — process documentation |

---

## The data bridge: `review-findings.md`

### What it is

A structured, append-only list of review findings. It is the only output the reviewer
writes. It is also the only input the development team needs to consult when addressing
critique. No review feedback exists outside this file.

### Schema — one block per finding

```
## F-XXX | SEVERITY | CATEGORY | STATUS

- **Location:** file path and line range (or endpoint + method)
- **Issue:** What is wrong or missing (factual statement, not opinion).
- **Evidence:** Where the problem is visible — curl output, spec excerpts, line numbers.
- **Suggestion:** Concrete action the team can take.
- **Status:** open | addressed | rejected
```

All five fields are mandatory. The header line is machine-parseable:
split on ` | ` to extract ID, severity, category, and status.

### Severity levels

| Level | Meaning | Example |
|-------|---------|---------|
| `critical` | Blocks release or breaks consumers | An endpoint returns 200 for invalid input that the spec declares as 4xx; a required response field is missing |
| `major` | Weakens reliability or correctness | An open Known Issue in README is not tracked in the spec; error responses are not JSON-structured |
| `minor` | Polish | A port number in README differs from the Dockerfile EXPOSE line; a description in openapi.yaml is misleading |

### Categories

| Category | What is checked |
|----------|-----------------|
| `api-correctness` | Endpoint behaviour matches `current_build/openapi.yaml` schema and status codes |
| `documentation` | `README.md`, `openapi.yaml` descriptions, `TestCase.md` accuracy and completeness |
| `code-quality` | Go idioms, error handling, security, logging hygiene |
| `docker` | `Dockerfile` correctness, image size, security posture, build reproducibility |
| `test-coverage` | Missing or untested edge cases relative to the open Known Issues list |
| `consistency` | Known-issues list, version strings, port numbers, endpoint names match across all files |

### Status lifecycle

```
open        →  addressed   (team has resolved the finding)
open        →  rejected    (team reviewed and consciously decided not to act)
addressed   →  open        (reopened — reviewer verification found the response
                             incomplete or introduced a new problem)
```

Changing the status alone is **not** sufficient. Every status change requires a
**Response** field to be added to the finding block. The Response field is the
record of what was done — it is what makes the findings file auditable and what
lets the reviewer (or another agent) verify that the issue is actually closed.

### How to mark work done

When you act on a finding, do two things:

1. Change the status in the header line (`open` → `addressed` or `rejected`).
2. Add a `- **Response:**` field to the block, directly after `- **Suggestion:**`.

#### Format for `addressed`

```
- **Response:** [date] — [what was changed] in [file:line or endpoint]. [One sentence
  on why this resolves the issue, if not obvious.]
```

Example:

```
- **Response:** 2026-02-21 — Updated `/rules/show` handler to return 400 with a
  structured JSON error body when `sid` is missing. Verified with curl against
  current_build/SemaLogic. openapi.yaml updated to document the 400 response schema.
```

#### Format for `rejected`

```
- **Response:** [date] — [one or two sentences explaining the rationale for not acting.]
```

Example:

```
- **Response:** 2026-02-21 — The `/StopServer` endpoint intentionally accepts any
  caller without authentication in the current research deployment. Securing it is
  deferred until the service moves to a multi-tenant environment.
```

#### Partial progress

If a finding is only partly resolved, keep the status as `open`. Add a Response
entry noting what was done so far and what remains. Multiple Response entries on
the same finding are allowed — append, do not overwrite.

```
- **Response:** 2026-02-21 — Fixed the ASP.json export for simple symbol cases.
  Nested attrib shadowing (the second sub-case in the issue) still unresolved.
```

#### Reopening an addressed finding

If the reviewer verifies the Response and finds the issue unresolved, or that the
correction introduced a new error, the finding is reopened: status moves back to
`open`. A new Response entry is appended explaining why the finding was reopened.
The finding keeps its original ID; the header status is changed back to `open`.

```
- **Response:** 2026-02-21 — Reopened. The fix correctly handles the top-level
  symbol case but the regression test in TestCase.md now fails for nested time terms.
  The underlying export logic remains incorrect.
```

### ID numbering

IDs are sequential and permanent: `F-001`, `F-002`, …
A finding is never renumbered or deleted, even after it is addressed or rejected.
This keeps the history intact for audit and for other agents that may reference
findings by ID.

---

## Session workflow

### How a review session works

1. **Team directs scope.** Tell the reviewer which area to review.
   Example: *"Review the `/rules/show` endpoint and its openapi.yaml definition."*
2. **Reviewer reads the relevant files** (`openapi.yaml`, source handlers, `README.md`,
   `Dockerfile` as applicable) and writes findings into `review-findings.md`.
3. **Reviewer reports in chat** only a summary: which IDs were added and the
   severity breakdown. No prose critique in chat.
4. **Team works against the findings list.** Update status to `addressed` or
   `rejected` as each item is resolved.

### What the reviewer does not do

- Rewrite or "improve" implementation code beyond what is necessary to demonstrate a fix.
- Second-guess deliberate architectural decisions without evidence of a concrete defect.
- Deliver critique as chat messages — everything goes into the file.
- Create duplicate findings. If an issue already exists, the existing entry is updated.

---

## Integration with the rest of the repo

| Concern | Where it lives |
|---------|----------------|
| API contract | `current_build/openapi.yaml` |
| Deployment definition | `Dockerfile` |
| Human documentation | `README.md` |
| Functional test cases | `TestCase.md` |
| Agent test instructions | `TEST.md` |
| Agent dev instructions | `DEVEL.md` |
| Review findings | `review/review-findings.md` (this directory) |

### Relationship to GitHub issues

`review-findings.md` and GitHub issues serve different purposes:

- Use **GitHub issues** for defects that need to be tracked publicly, prioritised in
  a backlog, or assigned to a milestone.
- Use **`review-findings.md`** for findings that are too detailed or exploratory for a
  single issue, for findings that span multiple files, or when the team prefers a
  self-contained review cycle without external tooling.

A finding may reference a GitHub issue by number (`Related to #42`). A GitHub issue
may reference a finding by ID (`See review/review-findings.md F-007`).

The findings file is deliberately format-neutral (plain Markdown). It can be read
by any tool, any agent, or any human without special software.
