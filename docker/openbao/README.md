# OpenBao - NAS Docker Compose

OpenBao runs on the NAS as the central secrets backend for the homelab.
ESO (External Secrets Operator) in the K8s cluster connects to it to sync
secrets into native Kubernetes Secrets.

## First-time setup

```bash
# Start OpenBao
docker compose up -d

# Initialize OpenBao (only once, ever)
docker exec -it openbao bao operator init \
  -key-shares=5 \
  -key-threshold=3

# IMPORTANT: Save the 5 unseal keys and root token immediately.
# You will need 3 of the 5 keys to unseal after every restart.

# Unseal (run 3 times with different keys)
docker exec -it openbao bao operator unseal
docker exec -it openbao bao operator unseal
docker exec -it openbao bao operator unseal

# Verify status
docker exec -it openbao bao status
```

## After NAS reboot

OpenBao starts sealed after every restart. It must be unsealed manually:

```bash
docker exec -it openbao bao operator unseal  # key 1
docker exec -it openbao bao operator unseal  # key 2
docker exec -it openbao bao operator unseal  # key 3
```

> **Note:** While sealed, ESO cannot fetch new secrets. Existing K8s Secrets
> (cached by ESO) continue working. Unseal promptly after any NAS reboot.

## Configure for ESO (AppRole auth)

```bash
export BAO_ADDR=http://127.0.0.1:8200
export BAO_TOKEN=<root-token>

# Enable KV v2 secrets engine
docker exec -it openbao bao secrets enable -path=secret kv-v2

# Enable AppRole auth method
docker exec -it openbao bao auth enable approle

# Create a read-only policy for ESO
docker exec -it openbao bao policy write eso-read-policy - <<EOF
path "secret/data/*" {
  capabilities = ["read", "list"]
}
path "secret/metadata/*" {
  capabilities = ["read", "list"]
}
EOF

# Create an AppRole for ESO
docker exec -it openbao bao write auth/approle/role/external-secrets \
  policies="eso-read-policy" \
  token_ttl=1h \
  token_max_ttl=4h \
  secret_id_num_uses=0 \
  token_num_uses=0

# Get the RoleID (store this in the ClusterSecretStore)
docker exec -it openbao bao read auth/approle/role/external-secrets/role-id

# Generate a SecretID (store this as a K8s secret via SOPS)
docker exec -it openbao bao write -f auth/approle/role/external-secrets/secret-id
```

## Adding secrets

```bash
# Example: Grafana admin credentials
docker exec -it openbao bao kv put secret/monitoring/grafana \
  admin-user=admin \
  admin-password=<your-password>

# Example: Pi-hole API key
docker exec -it openbao bao kv put secret/apps/pihole \
  api-key=<your-api-key>
```

## Backup

Raft snapshots capture the full OpenBao state:

```bash
# TODO: Automate backups
docker exec -it openbao bao operator raft snapshot save /openbao/data/backup.snap
# Then copy backup.snap to a safe location
```
