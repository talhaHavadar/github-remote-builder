#!/bin/bash

current_repo=$(git remote -v | grep github | head -1 | sed 's/.*://' | sed 's/\.git.*//')
current_branch=$(git branch | grep '*' | sed 's/.*\s//')

while [ -n "${1-}" ]; do
    case "$1" in
        --help)
            # usage
            exit
            ;;
        --arch=*)
            ARCH="${1#*=}"
            ;;
        --target-repo=*)
            TARGET_REPO="${1#*=}"
            ;;
        --target-ref=*)
            TARGET_REF="${1#*=}"
            ;;
        --prebuild-command=*)
            PREBUILD_COMMAND="${1#*=}"
            ;;
        --build-command=*)
            BUILD_COMMAND="${1#*=}"
            ;;
        --target-files=*)
            TARGET_FILES="${1#*=}"
            ;;
        *)
            echo "ERROR: unknown option $1"
            # usage
            exit 1
            ;;
    esac
    shift
done

ARCH=${ARCH:-amd64}
TARGET_REPO=${TARGET_REPO:-$current_repo}
TARGET_REF=${TARGET_REF:-$current_branch}

gh workflow run -R talhaHavadar/github-remote-builder \
    $ARCH-build.yaml \
    -f target_repo=$TARGET_REPO \
    -f target_ref=$TARGET_REF \
    -f prebuild_command="curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && cargo install cargo-deb" \
    -f build_command='cargo deb' -f target_files="target/debian"

sleep 4s

run_id=$(gh run -R talhaHavadar/github-remote-builder list --workflow amd64-build.yaml | head -1 | awk -v FS='\t' '{ print $7}')

gh run -R talhaHavadar/github-remote-builder watch $run_id && \
    gh run -R talhaHavadar/github-remote-builder download $run_id && \
    gh run -R talhaHavadar/github-remote-builder delete $run_id
