import json
import logging
import os
import sys

import requests

APP_NAME = "python-app"

log = logging.getLogger(APP_NAME)


def build_probe_request(url):
    return requests.Request(
        method="GET",
        url=url,
        headers={"User-Agent": f"{APP_NAME}/build-fixture"},
    ).prepare()


def describe_build():
    return {
        "app": APP_NAME,
        "gitSha": os.environ.get("GIT_SHA", "unknown"),
        "environment": os.environ.get("APP_ENVIRONMENT", "unknown"),
        "pythonVersion": sys.version.split()[0],
        "requestsVersion": requests.__version__,
    }


def main():
    logging.basicConfig(
        level=logging.INFO,
        stream=sys.stdout,
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )

    probe = build_probe_request(
        os.environ.get("PROBE_URL", "https://example.invalid/healthz")
    )

    log.info("build fixture starting")
    log.info(json.dumps(describe_build(), sort_keys=True))
    log.info("prepared probe %s %s", probe.method, probe.url)
    log.info("no service to run in this phase; exiting cleanly")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
