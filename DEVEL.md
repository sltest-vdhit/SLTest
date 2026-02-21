# SemaLogic — Agent Development Instructions

## Role

You are a **development agent**. You may read and modify source code, update the API
specification, write tests, and open pull requests. You are expected to leave the codebase
in a better state than you found it.

Your scope is broader than a testing agent: you diagnose root causes, implement fixes and
features, and verify that changes work end-to-end before committing.

---

## Build environment

| Requirement | Detail |
|-------------|--------|
| Language | Go (check `go version`; target the version in `go.mod` if present) |
| OS baseline | Ubuntu 24.04 (see `Dockerfile`) |
| Port | 28000 (default); override with `-p` |
| Pre-built artefacts | `current_build/` — do not edit these directly |

### Building from source

If source files are present in the repository (`.go` files), build with:

```bash
go build ./...
# or, if a Makefile is present:
make build
```

If only the pre-built binary is present in `current_build/`, note this in any PR and
ask the maintainers to expose the source.

### Verifying Docker parity

After any functional change, confirm the Docker image still builds and starts:

```bash
docker build -t $USER/semalogic .
docker run --rm -d --name semalogic-test $USER/semalogic
# readiness check
curl -s http://$(docker inspect semalogic-test | \
  python3 -c "import sys,json; print(json.load(sys.stdin)[0]['NetworkSettings']['IPAddress'])"):28000/APIVersion
docker stop semalogic-test
```

---

## Project layout

```
SLTest/
├── README.md            Human-readable overview and known issues
├── TEST.md              Agent testing instructions
├── DEVEL.md             This file
├── TestCase.md          Canonical SemaLogic rule set (test input)
├── Dockerfile           Production container definition
├── current_build/
│   ├── SemaLogic        Pre-compiled binary (Linux x86-64)
│   ├── openapi.yaml     API contract — source of truth for external consumers
│   └── SemaLogic.svg    Visual overview
└── review/
    ├── REVIEW.md        Local review process (alternative to GitHub issues)
    └── review-findings.md  Accumulated review findings (append-only)
```

---

## API contract first

`current_build/openapi.yaml` is the authoritative specification for every external consumer
(Swagger Inspector, test agents, integration partners). Treat it as the contract.

**Rule:** Any change to endpoint behaviour, request schema, or response schema requires a
corresponding update to `openapi.yaml` in the **same commit** as the code change. Never
let the spec drift from the implementation.

When editing `openapi.yaml`, validate it before committing:

```bash
# using swagger-cli (install once with: npm install -g @apidevtools/swagger-cli)
swagger-cli validate current_build/openapi.yaml

# or with vacuum (Go-native, fast):
vacuum lint current_build/openapi.yaml
```

---

## Coding conventions

- **Format:** Run `gofmt -w .` before every commit.
- **Vet:** Run `go vet ./...`; zero warnings required.
- **Errors:** Handle every `error` return explicitly. Do not discard errors with `_`.
- **Logging:** Use the existing logging pattern in the codebase; do not introduce a new
  logger without discussion.
- **Dependencies:** Do not add external dependencies without maintainer approval. Prefer
  the standard library.
- **Security:** Never log request bodies that may contain sensitive rule data at INFO
  level; use DEBUG. Do not expose internal stack traces in HTTP responses.

---

## Adding a new endpoint

Follow this checklist in order:

1. **Spec first** — Add the new path to `current_build/openapi.yaml`. Define request and
   response schemas completely.
2. **Validate the spec** — Run `swagger-cli validate` or `vacuum lint`.
3. **Implement the handler** — Follow existing handler patterns in the source.
4. **Test the handler** — Add a curl example to `TEST.md` under the endpoint table.
5. **Update documentation** — If the endpoint resolves an open issue, check the box in
   `README.md`. If it moves the roadmap forward, update the Roadmap section.
6. **Docker parity** — Run the Docker verification sequence above.
7. **Commit** — See commit discipline below.

---

## Fixing a known issue

1. Identify the open checkbox in `README.md` that corresponds to the issue.
2. Write a minimal reproduction using `TEST.md` methodology before touching code.
3. Implement the fix; confirm the reproduction no longer triggers the bug.
4. Mark the checkbox as `[x]` in `README.md` with the version where it was fixed.
5. If a GitHub issue exists, reference it in the commit body (`Closes #N`).

---

## Commit discipline

Use [Conventional Commits](https://www.conventionalcommits.org/):

| Type | When |
|------|------|
| `feat:` | New endpoint or new language feature support |
| `fix:` | Bug fix (reference the README known-issue or GitHub issue) |
| `docs:` | README, openapi.yaml, TEST.md, DEVEL.md changes only |
| `refactor:` | Internal restructuring, no behaviour change |
| `test:` | New or updated test cases in TestCase.md |
| `chore:` | Build, Docker, dependency updates |

**Commit message format:**

```
<type>: <imperative summary, ≤72 chars>

<body: what and why, not how. Reference issues with "Closes #N" or "Related to #N".>
```

Rules:
- Never use `--no-verify`.
- Never amend a commit that has already been pushed.
- Never force-push to `main`.
- Open a PR for every change that touches source or the API contract.

---

## Pull request checklist

Before opening a PR, confirm:

- [ ] `gofmt -w .` has been run and diff is clean.
- [ ] `go vet ./...` reports zero issues.
- [ ] `openapi.yaml` is updated and validates cleanly.
- [ ] Docker build succeeds and readiness check passes.
- [ ] `README.md` is updated if Known Issues or Roadmap changed.
- [ ] PR description links to the GitHub issue(s) it addresses.

---

## What the agent does NOT do

- Does not force-push to `main` or any protected branch.
- Does not amend commits that are already on the remote.
- Does not skip pre-commit hooks (`--no-verify`).
- Does not introduce external dependencies without explicit approval.
- Does not let `openapi.yaml` drift from the implementation.
- Does not call `/StopServer` in a production or shared environment.
