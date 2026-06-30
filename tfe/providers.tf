# Provider credentials come from sensitive WORKSPACE VARIABLES in HCP, set as
# environment variables (env category):
#   NUTANIX_ENDPOINT = 192.168.0.39      (Prism Central host/IP, no scheme, no port)
#   NUTANIX_PORT     = 9440
#   NUTANIX_USERNAME = admin
#   NUTANIX_PASSWORD = <prism password>  (mark Sensitive)
#   NUTANIX_INSECURE = true              (CE uses a self-signed cert)
#
# Because all five are read from NUTANIX_* env vars, the provider block can be
# nearly empty. Nothing secret lives in code or in git.

provider "nutanix" {
  # All values sourced from NUTANIX_* environment variables in the workspace.
  # Left explicit-but-empty here for documentation; remove if you prefer.
}
