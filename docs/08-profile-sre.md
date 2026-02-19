# Profile: SRE / DevOps

**Script:** `steps/08-profile-sre.sh`
**Flag:** `--profiles sre`

Installs the full cloud-native and infrastructure toolchain for Site Reliability Engineers and DevOps practitioners.

---

## Tools installed

### Docker

Installed via the official `get.docker.com` convenience script. The current user is added to the `docker` group (re-login required to use Docker without `sudo`).

```bash
docker --version
docker compose version
```

### Docker Compose (v2)

Installed as a Docker CLI plugin at `/usr/local/lib/docker/cli-plugins/docker-compose`. Uses the latest release from `docker/compose` GitHub.

### kubectl

Downloaded directly from `dl.k8s.io` at the latest stable version. Installed to `~/.local/bin/kubectl`.

```bash
kubectl version --client
```

### kubectx + kubens

Downloaded from `ahmetb/kubectx` GitHub releases. Installed to `~/.local/bin/`.

- `kubectx` — switch Kubernetes contexts
- `kubens` — switch namespaces

### Helm

Installed via the official Helm installer script (`get-helm-3`).

```bash
helm version --short
```

### k9s

Downloaded from `derailed/k9s` GitHub releases. A terminal UI for Kubernetes clusters.

```bash
k9s
```

### stern

Downloaded from `stern/stern` GitHub releases. Streams and tails logs from multiple Kubernetes pods simultaneously.

```bash
stern <pod-name-pattern>
```

### lazydocker

Installed via the official `lazydocker` installer script. Terminal UI for managing Docker containers, images, and volumes.

```bash
lazydocker
```

### Terraform

Installed from the official HashiCorp apt repository (`apt.releases.hashicorp.com`).

```bash
terraform version
```

### Ansible

Installed via `apt-get install ansible` or `pipx install ansible-core` as fallback.

```bash
ansible --version
```

### AWS CLI v2

Downloaded from `awscli.amazonaws.com` and installed system-wide via the official installer.

```bash
aws --version
```

### Google Cloud SDK (`gcloud`)

Installed from the official Google Cloud apt repository (`packages.cloud.google.com`). Includes `gcloud`, `gsutil`, `bq`.

```bash
gcloud --version
```

### Flux CLI

Installed via the official FluxCD installer script (`fluxcd.io/install.sh`). Used for GitOps with Flux v2.

```bash
flux --version
```

---

## Powerlevel10k integration

The SRE profile benefits from context-sensitive prompt segments already configured in `~/.p10k.zsh`:

| Segment | Appears when |
|---------|-------------|
| `kubecontext` | Running `kubectl`, `helm`, `k9s`, `flux`, `stern`, etc. |
| `terraform` | Running `terraform`, `terragrunt`, `packer` |
| `aws` | Running `aws`, `cdk`, `awless` |

---

## Progress key

`08-profile-sre.sh` is written to `~/.dev-setup.progress` on success.
