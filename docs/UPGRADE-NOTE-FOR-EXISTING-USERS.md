# Upgrade Note for Existing VibeOS Users

**Copy this and send it to your users.**

---

## VibeOS Upgrade — Copy and Paste This

Open your project and paste this into your agent:

```
Run this command from my project directory:

mkdir -p ~/.vibeos-cache && (test -d ~/.vibeos-cache/VibeOS-2 && (cd ~/.vibeos-cache/VibeOS-2 && git pull) || git clone https://github.com/chieflatif/VibeOS-2 ~/.vibeos-cache/VibeOS-2) && bash ~/.vibeos-cache/VibeOS-2/helpers/fetch-and-upgrade.sh . https://github.com/chieflatif/VibeOS-2
```

That's it. Your gates and scripts update. Your config stays the same.
