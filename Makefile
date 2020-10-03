.DEFAULT_GOAL := help

# Files
README_FILE := README.md
CHANGELOG_FILE := CHANGELOG.md
MIX_FILE := mix.exs

# Data
APP := $(shell sed -En "s/^.*@app (:{1})(.*)/\\1\\2/p" ${MIX_FILE})
NAME := $(shell sed -En "s/^.*@name \"(.*)\"/\\1/p" ${MIX_FILE})
REPO := $(shell sed -En "s/^.*@repo \"(.*)\"/\\1/p" ${MIX_FILE})
VERSION := $(shell sed -En "s/^.*@version \"([0-9]*\\.[0-9]*\\.[0-9]*)\"*/\\1/p" ${MIX_FILE})
MAJOR := $(shell echo "${VERSION}" | cut -d . -f1)
MINOR := $(shell echo "${VERSION}" | cut -d . -f2)
PATCH := $(shell echo "${VERSION}" | cut -d . -f3)
REPO_COMPARE := $(shell echo "${REPO}/compare" | sed "s/\//\\\\\//g")
DATE := $(shell date +"%Y-%m-%d")

# Colors
DEFAULT_COLOR := \033[0;39m
DIM_COLOR := \033[0;2m
LIGHT_MAGENT_COLOR := \033[0;95m
YELLOW_COLOR := \033[0;33m

.PHONY: help
help: ## Print this help
	@printf "${NAME} v${VERSION}\n"
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "${LIGHT_MAGENT_COLOR}%-30s${YELLOW_COLOR} %s\n", $$1, $$NF }' $(MAKEFILE_LIST)

.PHONY: full-test
full-test: ## Runs Elixir format, Credo, Dialyzer, and unit tests with coverage.
	@printf "${YELLOW_COLOR}--------------------------------------------\n"
	@printf "Elixir format\n"
	@printf "${YELLOW_COLOR}--------------------------------------------${DEFAULT_COLOR}\n"
	mix format --check-formatted
	@printf "\n${YELLOW_COLOR}--------------------------------------------\n"
	@printf "Credo\n"
	@printf "${YELLOW_COLOR}--------------------------------------------${DEFAULT_COLOR}\n"
	mix credo --strict
	@printf "${YELLOW_COLOR}--------------------------------------------\n"
	@printf "Dialyzer\n"
	@printf "${YELLOW_COLOR}--------------------------------------------${DEFAULT_COLOR}\n"
	mix dialyzer
	@printf "\n${YELLOW_COLOR}--------------------------------------------\n"
	@printf "Unit tests\n"
	@printf "${YELLOW_COLOR}--------------------------------------------${DEFAULT_COLOR}\n"
	mix test --cover --trace

.PHONY: release
release: ## Bumps the version and creates a new tag
	@printf "${LIGHT_MAGENT_COLOR}The current version is:${YELLOW_COLOR} ${VERSION}${DEFAULT_COLOR}\n" && \
	  read -r -p "Which version do you want to release? [major|minor|patch] " TYPE && \
	  case "$$TYPE" in \
	  "major") \
	    MAJOR=$$((${MAJOR}+1)); \
	    MINOR="0"; \
	    PATCH="0"; \
	    NEW_VERSION="$$MAJOR.$$MINOR.$$PATCH" \
	    ;; \
	  "minor") \
	    MINOR=$$((${MINOR}+1)); \
	    PATCH="0" && \
	    NEW_VERSION="${MAJOR}.$$MINOR.$$PATCH" \
	    ;; \
	  "patch") \
	    PATCH=$$((${PATCH}+1)); \
	    NEW_VERSION="${MAJOR}.${MINOR}.$$PATCH" \
	    ;; \
	  *) \
	    printf "\\n${YELLOW_COLOR}Release canceled!\n"; \
	    exit 0 \
	    ;; \
	  esac && \
	  printf "${LIGHT_MAGENT_COLOR}The new version is:${YELLOW_COLOR} $$NEW_VERSION\n" && \
	  printf "\t${DIM_COLOR}Updating version in ${MIX_FILE}${DEFAULT_COLOR}\n" && \
	  perl -p -i -e "s/@version \"${VERSION}\"/@version \"$$NEW_VERSION\"/g" ${MIX_FILE} && \
	  printf "\t${DIM_COLOR}Updating version in ${README_FILE}${DEFAULT_COLOR}\n" && \
	  perl -p -i -e "s/{:miss, \"~> ${VERSION}\"}/{:miss, \"~> $$NEW_VERSION\"}/g" ${README_FILE} && \
	  printf "\t${DIM_COLOR}Updating version in ${CHANGELOG_FILE}${DEFAULT_COLOR}\n" && \
	  perl -p -i -e "s/## \[Unreleased\]/## \[Unreleased\]\\n\\n## \[$$NEW_VERSION\] - ${DATE}/g" ${CHANGELOG_FILE} && \
	  perl -p -i -e "s/${REPO_COMPARE}\/${VERSION}...master/${REPO_COMPARE}\/$$NEW_VERSION...master/g" ${CHANGELOG_FILE} && \
	  perl -p -i -e "s/...master/...master\\n\[$$NEW_VERSION\]: ${REPO_COMPARE}\/${VERSION}...$$NEW_VERSION/g" ${CHANGELOG_FILE} && \
	  printf "\t${DIM_COLOR}Recording changes to the repository${DEFAULT_COLOR}\n" && \
	  git add ${MIX_FILE} ${README_FILE} ${CHANGELOG_FILE} && \
	  git commit -m "Bump to version $$NEW_VERSION." > /dev/null && \
	  printf "\t${DIM_COLOR}Creating release tag${DEFAULT_COLOR}\n" && \
	  git tag -a -m "" $$NEW_VERSION && \
	  printf "\n${DEFAULT_COLOR}Review the changes before push them to the repository.\n"
