# aws-cicd-demo-python-app

A Python containerization fixture that consumes
[aws-cicd-framework](https://github.com/loriamichaelj/aws-cicd-framework).

This repository carries **no functional application logic, by design**. It exists to give
the framework's build, lint, and containerization steps a real artifact to operate on. It
does not bind a port, serve traffic, or need to run in order to be considered complete.
The engineering on display is the Dockerfile and the pipeline that consumes it.

AWS resources built from this repository use the logical app name **`python-app`** —
deliberately decoupled from the GitHub repository name, which carries the `aws-cicd-`
prefix only for grouping on GitHub.

## Layout

```
src/app.py          no-op entrypoint; prints a build descriptor and exits 0
requirements.txt    one real pinned dependency (requests)
Dockerfile          multi-stage, non-root, healthchecked
.dockerignore       keeps VCS metadata, virtualenvs and caches out of the build context
```

## Dockerfile discipline

The framework enforces a `hadolint` step that fails the pipeline on any error-level
finding. This Dockerfile is written against that bar:

| Requirement | How it is met |
| --- | --- |
| Multi-stage build | `builder` compiles the virtualenv; `runtime` copies only the finished venv |
| Non-root with explicit UID | dedicated `app` user, `USER 10001` |
| Pinned base image | `python:3.12-slim`, never `:latest` |
| Pinned dependencies | `requests==2.34.2` in `requirements.txt` |
| No build tooling in final image | pip cache disabled, no compilers carried forward |
| Dependency install before source copy | `requirements.txt` copied and installed before `src/` |
| Healthcheck present | `HEALTHCHECK` importing the module |
| OCI labels present | `org.opencontainers.image.*` on the runtime stage |
| No secrets in any layer | nothing sensitive enters the build context |

## Local checks

These are the same commands the pipeline runs, so failures reproduce locally:

```bash
python -m compileall -q src
docker build -t python-app:local .
docker run --rm python-app:local
hadolint Dockerfile
```

## Branches

`main` is the default and holds the deliverable. `dev` is where work happens.

`stage` and `prod` exist as **GitHub Environments**, not branches. Promotion to them is a
manually dispatched workflow that copies the already-built artifact forward behind an
approval gate — the image is never rebuilt per environment, so the image digest referenced
in `prod` is provably identical to the one built on `dev`.
