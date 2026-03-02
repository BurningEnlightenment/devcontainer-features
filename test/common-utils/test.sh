#!/bin/bash
set -e
source dev-container-features-test-lib

check "delta installed" delta --version
check "fd installed" fd --version
check "ripgrep installed" rg --version
check "scooter installed" scooter --version
check "sd installed" sd --version

reportResults
