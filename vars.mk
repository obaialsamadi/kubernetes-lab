DELAY:=5
# container specific vars
PRIVILEGED_CONTAINER_SUPPORT:=true
LXC_IMAGE:=images:debian/buster
CONTAINER_COUNT:=3

# ansible specific
VAULT_PASSWORD_FILE=~/.vault_pass.txt