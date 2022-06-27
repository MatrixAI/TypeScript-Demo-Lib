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
# Cached directories shared between jobs & pipelines per-branch per-runner
cache:
  key: $CI_COMMIT_REF_SLUG
  paths:
    - ./tmp/npm/
    - ./tmp/ts-node-cache/
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
cat << "EOF"
check:test:
  stage: check
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
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  rules:
    # Runs on staging commits and ignores version commits
    - if: $CI_COMMIT_BRANCH =~ /^feature.*$/ && $CI_COMMIT_TITLE !~ /^[0-9]+\.[0-9]+\.[0-9]+(?:-.*[0-9]+)?$/
    # Manually run on commits other than master and staging and ignore version commits
    - if: $CI_COMMIT_BRANCH && $CI_COMMIT_BRANCH !~ /^(?:master|staging)$/ && $CI_COMMIT_TITLE !~ /^[0-9]+\.[0-9]+\.[0-9]+(?:-.*[0-9]+)?$/
      when: manual
EOF

printf "\n"
