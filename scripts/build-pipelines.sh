#!/usr/bin/env bash

shopt -s globstar
shopt -s nullglob

# Quote the heredoc to prevent shell expansion
cat << "EOF"
workflow:
  rules:
    # Disable merge request pipelines
    - if: $CI_MERGE_REQUEST_ID
      when: never
    - when: always
default:
  interruptible: true
variables:
  GH_PROJECT_PATH: "MatrixAI/${CI_PROJECT_NAME}"
  GH_PROJECT_URL: "https://${GITHUB_TOKEN}@github.com/${GH_PROJECT_PATH}.git"
  GIT_SUBMODULE_STRATEGY: "recursive"
  # Cache .npm
  NPM_CONFIG_CACHE: "./tmp/npm"
  # Prefer offline node module installation
  NPM_CONFIG_PREFER_OFFLINE: "true"
  # `ts-node` has its own cache
  # It must use an absolute path, otherwise ts-node calls will CWD
  TS_CACHED_TRANSPILE_CACHE: "${CI_PROJECT_DIR}/tmp/ts-node-cache"
  TS_CACHED_TRANSPILE_PORTABLE: "true"
  # Homebrew cache only used by macos runner
  HOMEBREW_CACHE: "${CI_PROJECT_DIR}/tmp/Homebrew"
# Cached directories shared between jobs & pipelines per-branch per-runner
cache:
  key: $CI_COMMIT_REF_SLUG
  paths:
    - ./tmp/npm/
    - ./tmp/ts-node-cache/
    # Homebrew cache is only used by the macos runner
    - ./tmp/Homebrew
    # `jest` cache is configured in jest.config.js
    - ./tmp/jest/
stages:
  - build       # Cross-platform library compilation, unit tests
image: registry.gitlab.com/matrixai/engineering/maintenance/gitlab-runner
EOF

printf "\n"

# Using shards to optimise tests
# In the future we can incorporate test durations rather than using
# a static value for the parallel keyword

cat << "EOF"
build:linux:
  stage: build
  needs: []
  parallel: 2
  script:
    - >
        nix-shell --run '
        npm run build --verbose;
        npm test -- --ci --runInBand --coverage --shard=$CI_NODE_INDEX/$CI_NODE_TOTAL;
        '
  artifacts:
    when: always
    reports:
      junit:
        - ./tmp/junit/junit.xml
      coverage_report:
        coverage_format: cobertura
        path: ./tmp/coverage/cobertura-coverage.xml
    paths:
      # Only the build:linux preserves the dist
      - ./dist
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  rules:
    # Runs on staging commits and ignores version commits
    - if: $CI_COMMIT_BRANCH == 'staging' && $CI_COMMIT_TITLE !~ /^[0-9]+\.[0-9]+\.[0-9]+(?:-.*[0-9]+)?$/
    # Runs on tag pipeline where the tag is a prerelease or release version
    - if: $CI_COMMIT_TAG =~ /^v[0-9]+\.[0-9]+\.[0-9]+(?:-.*[0-9]+)?$/
EOF

printf "\n"

cat << "EOF"
build:windows:
  stage: build
  needs: []
  parallel: 2
  tags:
    - windows
  before_script:
    - choco install nodejs --version=16.14.2 -y
    - refreshenv
  script:
    - npm config set msvs_version 2019
    - npm install --ignore-scripts
    - $env:Path = "$(npm bin);" + $env:Path
    - npm run build --verbose
    - npm test -- --ci --runInBand --shard=$CI_NODE_INDEX/$CI_NODE_TOTAL
  artifacts:
    when: always
    reports:
      junit:
        - ./tmp/junit/junit.xml
  rules:
    # Runs on staging commits and ignores version commits
    - if: $CI_COMMIT_BRANCH == 'staging' && $CI_COMMIT_TITLE !~ /^[0-9]+\.[0-9]+\.[0-9]+(?:-.*[0-9]+)?$/
    # Runs on tag pipeline where the tag is a prerelease or release version
    - if: $CI_COMMIT_TAG =~ /^v[0-9]+\.[0-9]+\.[0-9]+(?:-.*[0-9]+)?$/
EOF

printf "\n"

cat << "EOF"
build:macos:
  stage: build
  needs: []
  parallel: 2
  tags:
    - shared-macos-amd64
  image: macos-11-xcode-12
  variables:
    HOMEBREW_NO_INSTALL_UPGRADE: "true"
    HOMEBREW_NO_INSTALL_CLEANUP: "true"
  before_script:
    - eval "$(brew shellenv)"
    - brew install node@16
    - brew link --overwrite node@16
    - hash -r
  script:
    - npm install --ignore-scripts
    - export PATH="$(npm bin):$PATH"
    - npm run build --verbose
    - npm test -- --ci --runInBand --shard=$CI_NODE_INDEX/$CI_NODE_TOTAL
  artifacts:
    when: always
    reports:
      junit:
        - ./tmp/junit/junit.xml
  rules:
    # Runs on staging commits and ignores version commits
    - if: $CI_COMMIT_BRANCH == 'staging' && $CI_COMMIT_TITLE !~ /^[0-9]+\.[0-9]+\.[0-9]+(?:-.*[0-9]+)?$/
    # Runs on tag pipeline where the tag is a prerelease or release version
    - if: $CI_COMMIT_TAG =~ /^v[0-9]+\.[0-9]+\.[0-9]+(?:-.*[0-9]+)?$/
EOF

printf "\n"
