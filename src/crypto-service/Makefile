.DEFAULT_GOAL:=help

.EXPORT_ALL_VARIABLES:

ifndef VERBOSE
.SILENT:
endif

# set default shell
SHELL=/usr/bin/env bash -o pipefail -o errexit

TAG ?= $(shell cat TAG)
POETRY_HOME ?= ${HOME}/.local/share/pypoetry
POETRY_BINARY ?= ${POETRY_HOME}/venv/bin/poetry
POETRY_VERSION ?= 1.3.2

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: show-version
show-version:  ## Display version
	echo -n "${TAG}"

.PHONY: build
build: ## Build crypto-service package
	echo "[build] Build crypto-service package."
	${POETRY_BINARY} build

.PHONY: install
install:  ## Install crypto-service with poetry
	@build/install.sh

.PHONY: image
image:  ## Build crypto-service image
	@build/image.sh

.PHONY: metrics
metrics: install ## Run crypto-service metrics checks
	echo "[metrics] Run crypto-service PEP 8 checks."
	${POETRY_BINARY} run flake8 --select=E,W,I --max-line-length 88 --import-order-style pep8 --statistics --count crypto_service
	echo "[metrics] Run crypto-service PEP 257 checks."
	${POETRY_BINARY} run flake8 --select=D --ignore D301 --statistics --count crypto_service
	echo "[metrics] Run crypto-service pyflakes checks."
	${POETRY_BINARY} run flake8 --select=F --statistics --count crypto_service
	echo "[metrics] Run crypto-service code complexity checks."
	${POETRY_BINARY} run flake8 --select=C901 --statistics --count crypto_service
	echo "[metrics] Run crypto-service open TODO checks."
	${POETRY_BINARY} run flake8 --select=T --statistics --count crypto_service tests
	echo "[metrics] Run crypto-service black checks."
	${POETRY_BINARY} run black --check crypto_service

.PHONY: unit-test
unit-test: install ## Run crypto-service unit tests
	echo "[unit-test] Run crypto-service unit tests."
	${POETRY_BINARY} run pytest tests/unit

.PHONY: integration-test
integration-test: install ## Run crypto-service integration tests
	echo "[unit-test] Run crypto-service integration tests."
	${POETRY_BINARY} run pytest tests/integration

.PHONY: coverage
coverage: install  ## Run crypto-service tests coverage
	echo "[coverage] Run crypto-service tests coverage."
	${POETRY_BINARY} run pytest --cov=crypto_service --cov-fail-under=90 --cov-report=xml --cov-report=term-missing tests

.PHONY: test
test: unit-test integration-test  ## Run crypto-service tests

.PHONY: docs
docs: install ## Build crypto-service documentation
	echo "[docs] Build crypto-service documentation."
	${POETRY_BINARY} run sphinx-build docs site

.PHONY: mypy
mypy: install  ## Run crypto-service mypy checks
	echo "[mypy] Run crypto-service mypy checks."
	${POETRY_BINARY} run mypy crypto_service
