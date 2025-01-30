#!/bin/bash
#
# Sets up environment variables and does a dry run execution of main.sh to test deleting files AWS S3.
#
# Usage: delete.sh

#region initialize common environment variables
export RUNNER_OS="Windows"
export GITHUB_REPOSITORY="foo/bar"
export GITHUB_RUN_ID="1"
export S3_ARTIFACTS_BUCKET="this-is-an-s3-bucket-name"
export DRY_RUN=true

# variables needed, but are usually defined by the GitHub runner
export RUNNER_TEMP="$TEMP"
export RUNNER_DEBUG=true
export GITHUB_OUTPUT=/dev/null
export GITHUB_STEP_SUMMARY=/dev/null
#endregion

#region delete single file
#region set up environment variables
echo "Initializing variables"
export INPUT_NAME="tempArchiveName"
export INPUT_USE_GLOB="true"
export INPUT_FAIL_ON_ERROR="true"
#endregion

#region run main script
echo "Running main.sh"
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/../scripts/main.sh"
#endregion
#endregion

#region delete array of files
#region set up environment variables
echo "Initializing variables"
export INPUT_NAME="tempArchiveName1 tempArchiveName2 tempArchiveName3"
export INPUT_USE_GLOB="true"
export INPUT_FAIL_ON_ERROR="true"
#endregion

#region run main script
echo "Running main.sh"
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/../scripts/main.sh"
#endregion
#endregion