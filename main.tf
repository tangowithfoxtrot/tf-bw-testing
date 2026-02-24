# --- data sources ---
# In Terraform, *data sources* are sources that can be read from but not written to.
# They are used to fetch data from external sources and make that data available for
# use in your Terraform configuration.

# LIST projects to `out/datasources/projects-list.json`
data "bitwarden-secrets_projects" "projects" {}

output "projects" {
  value = data.bitwarden-secrets_projects.projects
}

resource "local_file" "projects_json" {
  content  = jsonencode(data.bitwarden-secrets_projects.projects)
  filename = "out/datasources/projects-list.json"
}

# LIST secrets to `out/datasources/secrets-list.json`.
# Note that the list will NOT contain secret values
data "bitwarden-secrets_list_secrets" "secrets" {}

output "secrets" {
  value = data.bitwarden-secrets_list_secrets.secrets
}

resource "local_file" "secrets_json" {
  content  = jsonencode(data.bitwarden-secrets_list_secrets.secrets)
  filename = "out/datasources/secrets-list.json"
}

# GET secret details
data "bitwarden-secrets_secret" "secret" {
  # use the ID of the first secret from the list of secrets
  id = data.bitwarden-secrets_list_secrets.secrets.secrets[0].id
}

output "secret" {
  value = {
    id              = data.bitwarden-secrets_secret.secret.id
    key             = data.bitwarden-secrets_secret.secret.key
    # The actual secret value is marked sensitive and will not be printed to stdout
    # value          = data.bitwarden-secrets_secret.secret.value
    note            = data.bitwarden-secrets_secret.secret.note
    project_id      = data.bitwarden-secrets_secret.secret.project_id
    organization_id = data.bitwarden-secrets_secret.secret.organization_id
    creation_date   = data.bitwarden-secrets_secret.secret.creation_date
    revision_date   = data.bitwarden-secrets_secret.secret.revision_date
  }
}

# output the secret details to `out/datasources/secret-get.json`.
resource "local_file" "secret_get_json" {
  content  = jsonencode(data.bitwarden-secrets_secret.secret)
  filename = "out/datasources/secret-get.json"
}

# --- resources ---
# In Terraform, *resources* are the components that you want to create, update, or delete.
# They represent the infrastructure components that you want to manage with Terraform.
# Currently, only secret resources are supported by the Bitwarden Secrets Terraform provider.
# Projects are read-only data sources and cannot be created or managed with Terraform.

# CREATE/UPDATE a secret with a randomly generated value.
resource "bitwarden-secrets_secret" "db_admin_secret" {
  key        = "db_admin_password"

  # when no value is provided, the provider will generate a random value
  # value      = var.value 

  # Use the ID of the first project from the list of projects
  project_id = data.bitwarden-secrets_projects.projects.projects[0].id

  note       = "This is the password for the database admin user. Created with Terraform."
}

# output the created secret to `out/resources/created-secret.json`.
# the output of this should look something like the following:
# {
#     "avoid_ambiguous": false,
#     "creation_date": "2026-02-17 18:14:15.7386423 +0000 UTC",
#     "id": "5e0e345e-8ffb-4d62-8ba5-b3fb012c8c63",
#     "key": "db_admin_password",
#     "length": 64,
#     "lowercase": true,
#     "min_lowercase": 1,
#     "min_number": 1,
#     "min_special": 1,
#     "min_uppercase": 1,
#     "note": "This is the password for the database admin user. Created with Terraform.",
#     "numbers": true,
#     "organization_id": "383e6ed5-4e69-41b9-845c-b1a400ea788d",
#     "project_id": "d8abb93a-b719-49c1-9a39-b1c6011be7bd",
#     "revision_date": "2026-02-24 18:14:15.7386424 +0000 UTC",
#     "special": false,
#     "uppercase": true,
#     "value": "JaJi7WtIQDUofMY2AXlK1I83Ld6NSAYh7CFnXSgQMEDmhDu8yMCGKULVuGd5elmH"
# }
resource "local_file" "created_secret_json" {
  content  = jsonencode(bitwarden-secrets_secret.db_admin_secret)
  filename = "out/resources/created-secret.json"
}

# TODO: add a DELETE example. This could be tricky to demonstrate...