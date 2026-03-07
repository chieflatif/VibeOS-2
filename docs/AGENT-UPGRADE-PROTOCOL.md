# Agent Upgrade Protocol (Voice-Driven)

When the user wants to upgrade their governance to the latest VibeOS-2, they should be able to **just say it**. No manual git pull, no manual script running. You handle everything.

## Voice Triggers

Treat these as upgrade requests:

- "Upgrade VibeOS"
- "Update my governance"
- "Get the latest VibeOS"
- "Pull the latest governance"
- "Update governance from [URL]"
- "Upgrade from [URL or path]"

## What You Do

### 1. Resolve the Framework Source

**If user provides a URL** (e.g. `https://github.com/chieflatif/VibeOS-2` or `chieflatif/VibeOS-2`):

- Clone to `~/.vibeos-cache/VibeOS-2` (or pull if already cloned)
- Use that as the framework directory

**If user provides a path** (e.g. `~/VibeOS-2`):

- Use that path. Optionally run `git pull` there to get latest.

**If user provides neither:**

- Ask: "Where should I get the latest VibeOS from? You can give me the GitHub URL (e.g. https://github.com/chieflatif/VibeOS-2) or the path to your cloned copy."

### 2. Run the Upgrade

**One command does everything** (fetch + upgrade):

```bash
bash {framework_dir}/helpers/fetch-and-upgrade.sh {target_project_dir} [url]
```

- `target_project_dir` = current workspace (the user's project)
- `url` = optional; if provided, the script clones/pulls from it. Default: https://github.com/chieflatif/VibeOS-2

**If user gave a path** (not URL):

```bash
FRAMEWORK_DIR={path} bash {path}/helpers/upgrade.sh {target_project_dir}
```

### 3. Summarize What's New

After the upgrade, read `{framework_dir}/CHANGELOG.md` (Unreleased section) and summarize in plain English:

- What new capabilities they have
- What changed and why it matters
- Recommended next step (e.g. run a gate, check a new WO requirement)

## Example Flows

**User:** "Upgrade VibeOS from the GitHub repo"

**You:** "I'll fetch the latest VibeOS-2 from GitHub and upgrade your project. This will add any new gate scripts and merge new gates into your manifest. Your baselines and config stay as-is."

Then run:
```bash
bash ~/.vibeos-cache/VibeOS-2/helpers/fetch-and-upgrade.sh . https://github.com/chieflatif/VibeOS-2
```
(Or clone first if cache is empty, then run from the clone.)

**User:** "Update governance"

**You:** "I'll upgrade your governance. Do you have VibeOS-2 cloned somewhere, or should I use the default GitHub repo?"

If they say "use the repo" or "GitHub":
```bash
# Clone to cache if needed, then:
bash {cache}/helpers/fetch-and-upgrade.sh .
```

**User:** "Upgrade using ~/VibeOS-2"

**You:** "I'll pull the latest from your local copy and upgrade your project."

```bash
cd ~/VibeOS-2 && git pull
FRAMEWORK_DIR=$HOME/VibeOS-2 bash $HOME/VibeOS-2/helpers/upgrade.sh .
```

## Prerequisites

- `git` — to clone/pull the framework
- `bash`, `python3`, `jq` — for the upgrade script (same as bootstrap)

## What Gets Updated vs Preserved

| Updated | Preserved |
|---------|-----------|
| All gate scripts (overwritten) | known_baselines |
| New gates added to manifest | Your env vars in gate configs |
| gate-runner.sh | WO-INDEX, DEVELOPMENT-PLAN |
| | Governance docs (not overwritten) |
