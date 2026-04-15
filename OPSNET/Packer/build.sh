PACKER_LOG=1 packer build \
  -var-file="ops.pkrvars.hcl" \
  variables.pkr.hcl \
  templates/c2-server/ \
  templates/devbox/ \
  templates/kali/