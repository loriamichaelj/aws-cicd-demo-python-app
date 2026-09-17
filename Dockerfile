FROM python:3.12-slim AS builder

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PATH="/opt/venv/bin:${PATH}"

WORKDIR /build

RUN python -m venv /opt/venv

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt


FROM python:3.12-slim AS runtime

LABEL org.opencontainers.image.title="python-app" \
      org.opencontainers.image.description="Python containerization fixture for the aws-cicd-framework pipeline" \
      org.opencontainers.image.source="https://github.com/loriamichaelj/aws-cicd-demo-python-app" \
      org.opencontainers.image.vendor="loriamichaelj" \
      org.opencontainers.image.licenses="MIT"

ENV PATH="/opt/venv/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN groupadd --system --gid 10001 app \
    && useradd --system --uid 10001 --gid 10001 --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app

COPY --from=builder --chown=10001:10001 /opt/venv /opt/venv

COPY --chown=10001:10001 src/ ./

USER 10001

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["python", "-c", "import app"]

ENTRYPOINT ["python", "-m", "app"]
