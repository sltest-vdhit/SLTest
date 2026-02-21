# SemaLogic — Agent Testing Instructions

## Role

You are a **testing agent**. Your job is black-box API testing of the SemaLogic service and
structured reporting of defects as GitHub issues. You do **not** modify source code, do not
commit, and do not force-push anything. All communication to the development team goes through
GitHub issues.

---

## Prerequisites

Before starting, verify:

1. `curl` is available (`curl --version`).
2. `gh` (GitHub CLI) is available for issue creation (`gh --version`).
   If `gh` is not available, format issues as described in [Issue format](#issue-format) and
   report them as a summary to the user instead.
3. Decide on a runtime target — prefer **local** for speed, use **Docker** for full parity:

   | Mode | When to use |
   |------|-------------|
   | Local | Fast iteration; binary available in `current_build/` |
   | Docker | Final verification or when local binary fails to start |

---

## Starting the server

### Local

```bash
./current_build/SemaLogic
# Optional: change port
./current_build/SemaLogic -p 28000
```

### Docker

```bash
docker build -t $USER/semalogic .
docker run -d --name semalogic-service $USER/semalogic
docker inspect semalogic-service | grep IPAddress   # note the IP
```

### Readiness check

Do not proceed until the server responds successfully:

```bash
curl -s -o /dev/null -w "%{http_code}" \
  http://localhost:28000/APIVersion
# Expected: 200
```

Wait up to 10 seconds, retrying every second. If the server does not become ready,
report a startup failure issue and stop.

---

## Test scope

The authoritative list of endpoints is `current_build/openapi.yaml`. Read it before
running tests to capture any endpoint not listed below.

Primary functional test input: `TestCase.md` — it contains a real SemaLogic rule set
with known properties (720 solutions, specific module structure) that can be used to
validate `/rules/parse`, `/rules/show`, and `/canvas/convert`.

### Endpoints to cover

| Endpoint | Method | Minimal test |
|----------|--------|--------------|
| `/` | GET | HTTP 200, non-empty body |
| `/APIVersion` | GET | HTTP 200, JSON with `version` key |
| `/session` | POST | Create session → returns `sid` |
| `/session` | DELETE | Delete the session created above |
| `/rules/define` | POST | Define a minimal rule; assert 200 |
| `/rules/parse` | POST | Parse the rule set from `TestCase.md`; assert 200 |
| `/rules/show` | GET | Show the parsed tree; assert 200, non-empty `data` |
| `/rules/remove` | POST | Remove a rule term; assert 200 |
| `/canvas/convert` | POST | Send minimal Obsidian Canvas JSON; assert 200 |
| `/dialect/define` | POST | Define a minimal dialect; assert 200 |
| `/dialect/show` | GET | List dialects; assert 200 |
| `/dialect/remove` | POST | Remove the dialect; assert 200 |
| `/StopServer` | POST | Do **not** call this during test runs |

---

## Test methodology

### 1 — Happy-path tests

For each endpoint in the table above:
- Send a valid request with correct JSON and a valid session ID.
- Assert HTTP 200 and a non-empty response body.
- For endpoints returning structured data, assert the expected top-level keys are present.

### 2 — Edge-case tests

Run these for every endpoint that accepts a request body:

| Scenario | Input | Expected |
|----------|-------|----------|
| Malformed JSON | `{bad json}` | 4xx error, JSON error body |
| Missing required field | Valid JSON minus one required field | 4xx or specific error |
| Invalid session ID | `sid: "does-not-exist"` | 4xx or empty result (document actual behaviour) |
| Empty body | `{}` | 4xx or documented default behaviour |

### 3 — Known-issue validation

The README lists open issues. For each unchecked item, design a call that exercises the
described behaviour and record whether it is still reproducible:

| README issue | Relevant endpoint | How to test |
|---|---|---|
| Only first matching term exported to ASP.json | `/rules/show` with `format=ASP.json` | Define two rules for the same symbol; check only one appears |
| Dynamic groups miss used-only symbols | `/rules/show` | Define a symbol used but not defined; check its absence |
| Nested attrib shadowing | `/rules/define` + `/rules/show` | Define nested attribs with different leaf values; inspect output |
| Nested Time terms in SVG | `/rules/show` with `format=SVG` | Define a nested time term; inspect SVG output |

For each test: record the result as `CONFIRMED` (still broken), `FIXED` (no longer broken),
or `INCONCLUSIVE` (could not reproduce). Open or close GitHub issues accordingly.

---

## Issue format

Before opening a new issue, search existing issues:

```bash
gh issue list --repo <owner>/<repo> --search "<keyword>"
```

If a matching open issue exists, add a comment rather than duplicating it.

### New issue template

**Title:** `[<severity>] <Short description of the defect>`

Severity labels: `critical`, `major`, `minor` — apply as a GitHub label.

**Body:**

```
## Environment
- OS: <Linux/Windows/Docker>
- Binary version: <output of GET /APIVersion>
- Reproduction mode: <local | docker>

## Steps to reproduce
1. Start server
2. Send the following request:
   ```
   curl -X POST http://localhost:28000/<endpoint> \
     -H 'Content-Type: application/json' \
     -d '<payload>'
   ```
3. Observe the response

## Expected behaviour
<What the openapi.yaml specification or README states should happen>

## Actual behaviour
<Exact HTTP status code and response body>

## Severity rationale
<Why this severity was chosen>
```

### Filing with gh

```bash
gh issue create \
  --title "[major] <description>" \
  --label "major" \
  --body "$(cat issue-body.md)"
```

---

## What the agent does NOT do

- Does not modify any source file.
- Does not commit or push anything.
- Does not call `/StopServer` during a test run.
- Does not close or reopen issues without verifiable evidence.
- Does not open a duplicate issue if one already exists for the same defect.
