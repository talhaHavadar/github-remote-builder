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
        --out=*)
            DOWNLOAD_DIR="${1#*=}"
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
PREBUILD_COMMAND=${PREBUILD_COMMAND:-$(cat .gh-remote-builder/prebuild)}
BUILD_COMMAND=${BUILD_COMMAND:-$(cat .gh-remote-builder/build)}
TARGET_FILES=$(sed 's/;/ /g' <<< ${TARGET_FILES:-$(cat .gh-remote-builder/target-files)})
DOWNLOAD_DIR=${DOWNLOAD_DIR:-"target" }

gh workflow run -R talhaHavadar/github-remote-builder \
    $ARCH-build.yaml \
    -f target_repo=$TARGET_REPO \
    -f target_ref=$TARGET_REF \
    -f prebuild_command="$PREBUILD_COMMAND" \
    -f build_command="$BUILD_COMMAND" \
    -f target_files="$TARGET_FILES"

sleep 4s

run_id=$(gh run -R talhaHavadar/github-remote-builder list --workflow "$ARCH"-build.yaml | head -1 | awk -v FS='\t' '{ print $7}')

gh run -R talhaHavadar/github-remote-builder watch $run_id && \
    gh run -R talhaHavadar/github-remote-builder download $run_id -D "$DOWNLOAD_DIR" && \
    gh run -R talhaHavadar/github-remote-builder delete $run_id
