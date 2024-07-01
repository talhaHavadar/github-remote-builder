#!/bin/bash


gh workflow run amd64-build.yaml -f target_repo=talhaHavadar/governor.badgerd.nl -f target_ref=rust \
    -f prebuild_command="curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && cargo install cargo-deb" \
    -f build_command='cargo deb' -f target_files="target/debian"

sleep 4s

run_id=$(gh run list --workflow amd64-build.yaml | head -1 | awk -v FS='\t' '{ print $7}')

gh run watch $run_id && gh run download $run_id && gh run delete $run_id
