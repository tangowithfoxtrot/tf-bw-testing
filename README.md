> [!WARNING]
> This Terraform project will output sensitive information to the `out/` directory, including secret details. This is intended for testing purposes only. Do not use this project with real (sensitive) secrets.

# Bitwarden Terraform Testing

This project provides a `run` script to test the Bitwarden Secrets Terraform provider against your infrastructure in either production or test mode.

## Prerequisites

- **Terraform or OpenTofu**
- **GitHub CLI (`gh`)** - Required for downloading test provider artifacts
- **Bitwarden Access Token** - Your API token for authentication

## Quick Start

```bash
./run
```

Running the script with no arguments launches interactive mode, which guides you through the setup process.

## Environment Variables

- `BW_ACCESS_TOKEN` - Your Bitwarden access token (required)
- `EDITOR` or `VISUAL` - Used for editing `terraform.tfvars` in interactive mode (defaults to `vi`)
- `TF_BINARY` - Used to manually specify either `terraform` or `tofu` if you have both installed (optional). Defaults to `tofu` if available, otherwise `terraform`.

## Interactive Mode

When you run `./run` with no arguments, the script will:

1. **Configure `terraform.tfvars`** (if needed)
   - Opens your `$EDITOR` (or `$VISUAL`, defaults to `vi`)
   - Requires the following to be set: `api_url`, `identity_url`, `organization_id`

2. **Set up BW_ACCESS_TOKEN** (if not already set)
   - Prompts you to enter your Bitwarden access token
   - You can skip and set it manually if preferred

3. **Choose a mode:**
   - **1) prod** - Uses the latest released provider version from the registry
   - **2) test** - Uses a test provider build from a specific branch (you provide the branch name)
   - **3) help** - Shows usage information
   - **4) exit** - Exit without running

## Non-Interactive Mode

If you prefer to skip interactive mode and run commands directly:

### Production Mode

```bash
./run prod
```

Tests using the latest released provider version.

### Test Mode

```bash
./run test <branch-name>
```

Tests using a provider build from the specified GitHub branch. The script will:

- Find the latest successful workflow run for that branch
- Download the provider artifact
- Configure a local provider override
- Run Terraform with that provider

## Manual Steps (Without the `run` Script)

If you prefer to perform the steps manually without using the `run` script:

### 1. Configure terraform.tfvars

Create or update `terraform.tfvars` in the project root:

```hcl
api_url         = "https://api.bitwarden.com"
identity_url    = "https://identity.bitwarden.com"
organization_id = "<your-organization-id-here>"
# access_token    = "<your-access-token-here>" # optional; can also set BW_ACCESS_TOKEN env var instead
```

Replace `<your-organization-id-here>` with your actual organization ID. Replace `<your-access-token-here>` with your Bitwarden access token, or you can set it as an environment variable instead (see next step).

### 2. Set `BW_ACCESS_TOKEN` (if access_token is not set in terraform.tfvars)

Export your Bitwarden access token as an environment variable:

```bash
export BW_ACCESS_TOKEN="<your-access-token-here>"
```

### 3. Test with Production Provider

To test with the latest released provider version:

```bash
# Backup existing .terraformrc if it exists
[ -f ~/.terraformrc ] && mv ~/.terraformrc ~/.terraformrc.backup

# Initialize and plan
terraform init -upgrade
terraform plan
terraform apply -auto-approve

# Restore original .terraformrc
[ -f ~/.terraformrc.backup ] && mv ~/.terraformrc.backup ~/.terraformrc
```

### 4. Test with Provider Build from a Branch

To test with a provider build from a GitHub branch:

1. Download the test artifact from the GitHub Actions workflow for the branch you're testing against.
2. Extract the provider binary and place it in a local directory (e.g., `/tmp/test-artifact/`).
3. Create a `.terraformrc` in your home directory with the following content to override the provider:

```hcl
provider_installation {
  filesystem_mirror {
    path = "/tmp/test-artifact/"
  }
}
```

4. Run Terraform commands:

```bash
# `terraform init` should be skipped when using a local provider override; it will cause an error since the provider is not in the registry, so skip this step
terraform plan
terraform apply
```

## Configuration

### `terraform.tfvars`

Create or edit `terraform.tfvars` with your provider configuration:

```hcl
api_url         = "https://api.bitwarden.com"
identity_url    = "https://identity.bitwarden.com"
organization_id = "<your-organization-id-here>"
```
