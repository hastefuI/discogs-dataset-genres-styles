SHELL := /bin/bash

SCRIPTS := scripts

.DEFAULT_GOAL := help
.NOTPARALLEL:
.PHONY: help dump extract dataset test clean

help: ## Show the available targets
	@grep -E '^[a-z][a-z-]*:.*## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*## "}; {printf "  make %-9s %s\n", $$1, $$2}'

dump: ## Resolve and download the latest dump (about 10 GB)
	@f="$$($(SCRIPTS)/discogs-fetch-data-dump.sh)" && $(SCRIPTS)/discogs-download-data-dump.sh "$$f"

extract: ## Rebuild dist/ from the downloaded dump
	@f="$$(ls -1 discogs_*_releases.xml.gz 2>/dev/null | tail -1)"; \
		test -n "$$f" || { echo "No dump found. Run 'make dump' first." >&2; exit 1; }; \
		$(SCRIPTS)/discogs-extract-genres-styles.sh "$$f"

dataset: dump extract ## Download the dump and rebuild dist/

test: ## Run the test suite
	@npm test

clean: ## Remove the downloaded dump and the checksum
	@rm -f discogs_*_releases.xml.gz discogs_*_CHECKSUM.txt
