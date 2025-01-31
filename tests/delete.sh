#!/bin/bash
#
# Sets up environment variables and does a dry run execution of main.sh to test deleting files AWS S3.
#
# Usage: delete.sh

#region get script directory
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
#endregion

#region initialize common environment variables
# shellcheck disable=SC1091
export GITHUB_REPOSITORY="foo/bar"
export GITHUB_RUN_ID="1"

if [[ -f "$DIR/../env.sh" ]]; then
    echo "env file found, executing"
    # env.sh should define AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION (optional), and S3_ARTIFACTS_BUCKET
    # shellcheck disable=SC1091
    source "$DIR/../env.sh"
else
    echo "Executing dry run"
    export DRY_RUN=true
    export S3_ARTIFACTS_BUCKET="this-is-an-s3-bucket-name"
fi
#endregion

#region create test files to delete
if [[ "$DRY_RUN" != "true" ]]; then
    # create directory for test files
    mkdir -p "./tmp"

    # single key with glob
    touch "./tmp/test1-file1.tgz"
    touch "./tmp/test1-file2.tgz"

    # single key without glob
    touch "./tmp/test2-file1.tgz"

    # array of keys with glob
    touch "./tmp/test3-group1-file1.tgz"
    touch "./tmp/test3-group1-file2.tgz"
    touch "./tmp/test3-group2-file1.tgz"
    touch "./tmp/test3-group2-file2.tgz"

    # array of keys without glob
    touch "./tmp/test4-file1.tgz"
    touch "./tmp/test4-file2.tgz"

    echo "Test files created"

    # upload test files to s3
    KEY="$GITHUB_REPOSITORY/$GITHUB_RUN_ID"
    echo "Uploading test files to s3://$S3_ARTIFACTS_BUCKET/$KEY"
    aws s3 cp ./tmp "s3://$S3_ARTIFACTS_BUCKET/$KEY" --recursive
fi
#endregion

#region delete single key with glob
#region set up environment variables
echo "Initializing variables"
export INPUT_NAME="test1-file*"
export INPUT_USE_GLOB="true"
export INPUT_FAIL_ON_ERROR="true"
#endregion

#region run main script
echo "Running main.sh"
# shellcheck disable=SC1091
source "$DIR/../scripts/main.sh"
#endregion
#endregion

#region delete single key without glob
#region set up environment variables
echo "Initializing variables"
export INPUT_NAME="test2-file1"
export INPUT_USE_GLOB="false"
export INPUT_FAIL_ON_ERROR="true"
#endregion

#region run main script
echo "Running main.sh"
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/../scripts/main.sh"
#endregion
#endregion

#region delete array of keys with glob
#region set up environment variables
echo "Initializing variables"
export INPUT_NAME="test3-group1-file* test3-group2-file*"
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

#region delete array of keys without glob
#region set up environment variables
echo "Initializing variables"
export INPUT_NAME="test4-file1 test4-file2"
export INPUT_USE_GLOB="false"
export INPUT_FAIL_ON_ERROR="true"
#endregion

#region run main script
echo "Running main.sh"
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/../scripts/main.sh"
#endregion
#endregion