#!/bin/bash
# Deletes a tarball artifact from AWS S3.
#
# Usage: main.sh
#
# The following environment variables must be defined:
#   - INPUT_NAME - The name of the artifact
#   - INPUT_USE_GLOB - Indicates whether the name, or names, should be treated as glob patterns.
#   - INPUT_FAIL_ON_ERROR - Indicates whether the action should fail upon encountering an error.
#   - RUNNER_OS - the OS of the runner
#   - S3_ARTIFACTS_BUCKET - the name of the AWS S3 bucket to use
#   - AWS_ACCESS_KEY_ID - the AWS access key ID (optional if uploading to a public S3 bucket)
#   - AWS_SECRET_ACCESS_KEY - the AWS secret access key (optional if uploading to a public S3 bucket)
#   - DRY_RUN - whether to run without uploading to AWS (optional, set to true to enable dry run)
#

# exit immediately if an error occurs
set -e

#region import scripts
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/encoding.sh"
#endregion

#region read input arguments
echo "::debug::Inputs:"
echo "::debug::    INPUT_NAME:              $INPUT_NAME"
echo "::debug::    INPUT_USE_GLOB:          $INPUT_USE_GLOB"
echo "::debug::    INPUT_FAIL_ON_ERROR:     $INPUT_FAIL_ON_ERROR"
echo "::debug::    RUNNER_OS:               $RUNNER_OS"
echo "::debug::    S3_ARTIFACTS_BUCKET:     $S3_ARTIFACTS_BUCKET"
echo "::debug::    AWS_ACCESS_KEY_ID:       $AWS_ACCESS_KEY_ID"
echo "::debug::    AWS_SECRET_ACCESS_KEY:   $AWS_SECRET_ACCESS_KEY"
#endregion

#region validate input variables
# validate script input variables
if [[ "$INPUT_NAME" == "" ]]; then
    echo "::error::The values of 'INPUT_NAME' input is not specified"
    ERROR=true
fi

if [[ "$INPUT_USE_GLOB" == "" ]]; then
    echo "::error::The values of 'INPUT_USE_GLOB' input is not specified"
    ERROR=true
fi

if [[ "$INPUT_FAIL_ON_ERROR" == "" ]]; then
    echo "::error::The values of 'INPUT_MERGE_MULTIPLE' input is not specified"
    ERROR=true
fi

# validate github actions variables
if [[ "$RUNNER_OS" == "" ]]; then
    echo "::error::The values of 'RUNNER_OS' GitHub variable is not specified"
    ERROR=true
fi

if [[ "$GITHUB_REPOSITORY" == "" ]]; then
    echo "::error::The values of 'GITHUB_REPOSITORY' GitHub variable is not specified"
    ERROR=true
fi

if [[ "$GITHUB_RUN_ID" == "" ]]; then
    echo "::error::The values of 'GITHUB_RUN_ID' GitHub variable is not specified"
    ERROR=true
fi

if [[ "$DRY_RUN" != "true" ]]; then
    # check whether AWS credentials are specified and warn if they aren't
    if [[ "$AWS_ACCESS_KEY_ID" == "" || "$AWS_SECRET_ACCESS_KEY" == "" ]]; then
        echo "::warn::AWS_ACCESS_KEY_ID and/or AWS_SECRET_ACCESS_KEY is missing from environment variables."
        ERROR=true
    fi

    # check whether S3_ARTIFACTS_BUCKET is defined
    if [[ "$S3_ARTIFACTS_BUCKET" == "" ]]; then
        echo "::error::S3_ARTIFACTS_BUCKET is missing from environment variables."
        ERROR=true
    fi
fi

if [[ "$ERROR" == "true" ]]; then
    echo "::error::Input error(s) - exiting"

    if [[ "$INPUT_FAIL_ON_ERROR" == "true" ]]; then
        exit 1
    else
        return
    fi
else
    echo "::debug::Validation complete"
fi
#endregion

#region delete artifact tarball from S3 bucket
# Get AWS S3 bucket URI and ensure it starts with "s3://"
S3URI="$S3_ARTIFACTS_BUCKET"
if [[ "$S3URI" != s3://* ]]; then
    echo "::debug::Adding s3:// to bucket URI"
    S3URI="s3://$S3URI"
fi

echo "::debug::Reading the path string ($INPUT_NAME) into an array"
read -ra ARTIFACTS <<< "$INPUT_NAME"

for ARTIFACT_NAME in "${ARTIFACTS[@]}"; do
    # Build key to object in S3 bucket
    REPO="$GITHUB_REPOSITORY"
    RUN_ID="$GITHUB_RUN_ID"
    ENCODED_FILENAME="$(urlencode "$ARTIFACT_NAME").tgz"
    KEY="$REPO/$RUN_ID/$ENCODED_FILENAME"    

    echo "::debug::Deleting \"$S3URI/$KEY\" from S3"
    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ "$INPUT_FAIL_ON_ERROR" == "true" ]]; then
            trap 'echo "ERROR: There was an error deleting \"$S3URI/$KEY\"; exit $?"' SIGHUP SIGINT SIGQUIT SIGTERM SIGUSR1 SIGUSR2
        else 
            trap 'echo "ERROR: There was an error deleting \"$S3URI/$KEY\"; exit"' SIGHUP SIGINT SIGQUIT SIGTERM SIGUSR1 SIGUSR2
        fi

        if [[ "$INPUT_USE_GLOB" == "true" ]]; then
            aws s3 rm "$S3URI" --recursive --exclude "*" --include "$KEY"
        else
            aws s3 rm "$S3URI/$KEY"
        fi
    else
        if [[ "$INPUT_USE_GLOB" == "true" ]]; then
            echo "::debug::aws s3 rm \"$S3URI\" --recursive --exclude \"*\" --include \"$KEY\""
        else
            echo "::debug::aws s3 rm \"$S3URI/$KEY\""
        fi
    fi
    echo "::debug::$S3URI/$KEY deleted from AWS S3"
done
#endregion