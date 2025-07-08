#!/usr/bin/env bash
source load_env_vars.sh

# Configuration
SCOPES="openid,https://www.googleapis.com/auth/userinfo.email,https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/sqlservice.login,https://www.googleapis.com/auth/drive"

# Set strict mode for better error handling
set -euo pipefail

# Check if required environment variable is set
if [ -z "${GOOGLE_CLOUD_PROJECT}" ]; then
    echo "Error: GOOGLE_CLOUD_PROJECT environment variable must be set"
    exit 1
fi

# Check if required environment variable is set
if [ -z "${GCP_SERVICE_ACCOUNT_EMAIL}" ]; then
    echo "Error: GCP_SERVICE_ACCOUNT_EMAIL environment variable must be set"
    exit 1
fi

# Check if gcloud CLI is installed
if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI is not installed or not in PATH"
    exit 1
fi

echo "Revoke any currently used application default credentials?"
gcloud auth application-default revoke

# Configure impersonation
echo "Setting up service account impersonation..."
gcloud config set auth/impersonate_service_account "${GCP_SERVICE_ACCOUNT_EMAIL}"

# Set project from environment variable
echo "Setting project..."
gcloud config set project "${GOOGLE_CLOUD_PROJECT}"

# Generate ADC file with impersonation
echo "Generating Application Default Credentials..."
gcloud auth application-default login \
    --impersonate-service-account="${GCP_SERVICE_ACCOUNT_EMAIL}" \
    --scopes="${SCOPES}"

# Verify configuration
echo "Verifying configuration..."
CURRENT_SA=$(gcloud config get-value auth/impersonate_service_account)
echo "Impersonating service account: ${CURRENT_SA}"
