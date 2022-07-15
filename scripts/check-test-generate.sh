#!/usr/bin/env bash

shopt -s globstar
shopt -s nullglob

# Quote the heredoc to prevent shell expansion
cat << "EOF"
default:
  interruptible: true
  before_script:
    # Replace this in windows runners that use powershell
    # with `mkdir -Force "$CI_PROJECT_DIR/tmp"`
    - mkdir -p "$CI_PROJECT_DIR/tmp"

variables:
  GIT_SUBMODULE_STRATEGY: "recursive"
  GH_PROJECT_PATH: "MatrixAI/${CI_PROJECT_NAME}"
  GH_PROJECT_URL: "https://${GITHUB_TOKEN}@github.com/${GH_PROJECT_PATH}.git"
  # Cache .npm
  NPM_CONFIG_CACHE: "./tmp/npm"
  # Prefer offline node module installation
  NPM_CONFIG_PREFER_OFFLINE: "true"
  # `ts-node` has its own cache
  # It must use an absolute path, otherwise ts-node calls will CWD
  TS_CACHED_TRANSPILE_CACHE: "${CI_PROJECT_DIR}/tmp/ts-node-cache"
  TS_CACHED_TRANSPILE_PORTABLE: "true"

# Cached directories shared between jobs & pipelines per-branch per-runner
cache:
  key: $CI_COMMIT_REF_SLUG
  # Preserve cache even if job fails
  when: 'always'
  paths:
    - ./tmp/npm/
    - ./tmp/ts-node-cache/
    # Homebrew cache is only used by the macos runner
    - ./tmp/Homebrew
    # Chocolatey cache is only used by the windows runner
    - ./tmp/chocolatey/
    # `jest` cache is configured in jest.config.js
    - ./tmp/jest/

stages:
  - check       # Linting, unit tests

image: registry.gitlab.com/matrixai/engineering/maintenance/gitlab-runner
EOF

printf "\n"

# Using shards to optimise tests
# In the future we can incorporate test durations rather than using
# a static value for the parallel keyword

# Number of parallel shards to split the test suite into
CI_PARALLEL=2

cat << "EOF"
check:test:
  stage: check
  needs: []
EOF
cat << EOF
  parallel: $CI_PARALLEL
EOF
cat << "EOF"
  script:
    - >
      nix-shell --run '
      npm test -- --ci --coverage --shard=$CI_NODE_INDEX/$CI_NODE_TOTAL;
      '
  artifacts:
    when: always
    reports:
      junit:
        - ./tmp/junit/junit.xml
      coverage_report:
        coverage_format: cobertura
        path: ./tmp/coverage/cobertura-coverage.xml
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
EOF
