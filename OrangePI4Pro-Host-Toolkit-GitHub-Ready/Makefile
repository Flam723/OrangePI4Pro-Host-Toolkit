SHELL := /bin/bash
VERSION := $(shell cat VERSION)
NAME := OrangePI4Pro-v$(VERSION)

.PHONY: check package clean

check:
	find . -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
	bash -n bin/orangepi4pro
	@echo "Bash syntax checks passed."

package: check
	./scripts/package-release.sh

clean:
	rm -f releases/$(NAME).tar.gz releases/$(NAME).zip releases/SHA256SUMS
