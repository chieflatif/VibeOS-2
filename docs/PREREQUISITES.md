# Prerequisites

## Required Tools

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| Bash | 3.2+ | Gate scripts, hooks |
| Python | 3.7+ | Stub detection, OWASP checks, PII scanning |
| Git | 2.0+ | Version control |
| jq | 1.5+ | JSON parsing (manifest, gate configs) |

## Installation by OS

### macOS

All prerequisites are pre-installed or available via Homebrew:

```bash
# Python 3 (usually pre-installed on macOS 12+)
python3 --version

# jq
brew install jq

# Git (pre-installed with Xcode Command Line Tools)
git --version

# Verify all prerequisites
bash helpers/verify-prerequisites.sh
```

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install -y python3 python3-pip git jq

# Verify
bash helpers/verify-prerequisites.sh
```

### Windows (WSL)

Use Windows Subsystem for Linux:

```bash
# Install WSL (PowerShell as Admin)
wsl --install

# Inside WSL (Ubuntu):
sudo apt update
sudo apt install -y python3 python3-pip git jq

# Verify
bash helpers/verify-prerequisites.sh
```

## Optional Tools

These are not required but enhance specific gates:

### Python Projects
| Tool | Gate | Install |
|------|------|---------|
| ruff | validate-code-quality.sh | `pip install ruff` |
| mypy | validate-code-quality.sh | `pip install mypy` |
| pip-audit | validate-dependencies.sh | `pip install pip-audit` |
| pre-commit | Pre-commit hooks | `pip install pre-commit` |

### TypeScript/JavaScript Projects
| Tool | Gate | Install |
|------|------|---------|
| tsc | validate-code-quality.sh | `npm install -g typescript` |
| eslint | validate-code-quality.sh | `npm install -g eslint` |
| biome | validate-code-quality.sh | `npm install -g @biomejs/biome` |

### Go Projects
| Tool | Gate | Install |
|------|------|---------|
| golangci-lint | validate-code-quality.sh | `go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest` |
| govulncheck | validate-dependencies.sh | `go install golang.org/x/vuln/cmd/govulncheck@latest` |

### Rust Projects
| Tool | Gate | Install |
|------|------|---------|
| clippy | validate-code-quality.sh | `rustup component add clippy` |
| cargo-audit | validate-dependencies.sh | `cargo install cargo-audit` |

## Verification

Run the prerequisite checker:

```bash
bash helpers/verify-prerequisites.sh
```

This checks all required tools and reports missing optional tools.
