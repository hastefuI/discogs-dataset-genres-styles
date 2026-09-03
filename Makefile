SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

SCRIPTS := scripts
MARKER := <!-- LAST_UPDATED -->

.DEFAULT_GOAL := help
.NOTPARALLEL:
.PHONY: help dump extract stamp dataset test clean

# Resolves the most recent downloaded dump, or fails with a hint.
latest_dump = f="$$(ls -1 discogs_*_releases.xml.gz 2>/dev/null | tail -1)"; \
	test -n "$$f" || { echo "No dump found. Run 'make dump' first." >&2; exit 1; }

help: ## Show the available targets
	@grep -E '^[a-z][a-z-]*:.*## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*## "}; {printf "  make %-9s %s\n", $$1, $$2}'

dump: ## Resolve and download the latest dump (about 10 GB)
	@f="$$($(SCRIPTS)/discogs-fetch-data-dump.sh)" && $(SCRIPTS)/discogs-download-data-dump.sh "$$f"

extract: ## Rebuild dist/ from the downloaded dump
	@$(latest_dump); \
		$(SCRIPTS)/discogs-extract-genres-styles.sh "$$f"

stamp: ## Record the source dump in the README
	@$(latest_dump); \
		grep -q '$(MARKER)' README.md \
			|| { echo "Marker '$(MARKER)' not found in README.md" >&2; exit 1; }; \
		checksums="discogs_$${f:8:8}_CHECKSUM.txt"; \
		if [[ -f "$$checksums" ]] && grep -qF " $$f" "$$checksums"; then \
			sum="$$(grep -F " $$f" "$$checksums" | awk '{print $$1}')"; \
		else \
			echo "No checksum file found, hashing $$f ..." >&2; \
			sum="$$(sha256sum "$$f" | awk '{print $$1}')"; \
		fi; \
		line='$(MARKER)'"$$f [$${sum:0:8}] (extracted $$(date '+%Y-%m-%d'))"; \
		perl -i -pe "s|\Q$(MARKER)\E.*|$$line|" README.md; \
		echo "Stamped README.md: $$f [$${sum:0:8}]" >&2

dataset: dump extract stamp ## Download the dump and rebuild dist/

test: ## Run the test suite
	@npm test

clean: ## Remove the downloaded dump and the checksum
	@rm -f discogs_*_releases.xml.gz discogs_*_CHECKSUM.txt
