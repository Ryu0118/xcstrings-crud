SWIFTFORMAT := .nest/bin/swiftformat
SWIFTLINT := .nest/bin/swiftlint
DOCSYNC := .nest/bin/docsync
GITNAGG := .nest/bin/gitnagg

SWIFT_SOURCES := Package.swift Sources Tests

.PHONY: nest hooks setup format format-lint lint gitnagg test build release docsync docsync-update-checksum check

nest:
	rm -f .nest/bin/swiftformat .nest/bin/swiftlint .nest/bin/gitnagg .nest/bin/docsync
	./scripts/nest.sh bootstrap nestfile.yaml

hooks:
	./scripts/setup-hooks.sh

setup: nest hooks
	@if command -v mise >/dev/null 2>&1; then mise install; else echo "mise not found; skipping mise install"; fi

format:
	@test -x "$(SWIFTFORMAT)" || (echo "Run: make setup" && exit 1)
	"$(SWIFTFORMAT)" --cache ignore --config .swiftformat $(SWIFT_SOURCES)

format-lint:
	@test -x "$(SWIFTFORMAT)" || (echo "Run: make setup" && exit 1)
	"$(SWIFTFORMAT)" --cache ignore --lint --config .swiftformat $(SWIFT_SOURCES)

lint:
	@test -x "$(SWIFTLINT)" || (echo "Run: make setup" && exit 1)
	"$(SWIFTLINT)" lint --config .swiftlint.yml --force-exclude --quiet --no-cache

gitnagg:
	@test -x "$(GITNAGG)" || (echo "Run: make setup" && exit 1)
	"$(GITNAGG)" check --config .gitnagg.yml

test:
	swift test

build:
	swift build

release:
	swift build -c release

docsync:
	@test -x "$(DOCSYNC)" || (echo "Run: make setup" && exit 1)
	"$(DOCSYNC)" check --config docsync.yml

docsync-update-checksum:
	@test -x "$(DOCSYNC)" || (echo "Run: make setup" && exit 1)
	"$(DOCSYNC)" update-checksum --config docsync.yml

check: format-lint lint test docsync
