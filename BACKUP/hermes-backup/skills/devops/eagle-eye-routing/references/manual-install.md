# Manual Plugin Install — Eagle Eye on Hermes Agent

**Context:** Eagle Eye is a third-party plugin (not distributed as `.hpkg`). The `hermes plugins install willingning-coder/eagle-eye` command does not work because there is no packaged release. You must install manually.

**Hermes install location:** `/usr/local/lib/hermes-agent/` (system-wide, NOT under `~/.hermes`)
**Hermes venv:** `/usr/local/lib/hermes-agent/venv/bin/python`
**User skills:** `~/.hermes/skills/`

## Step-by-step (tested 2026-07-02)

### 1. Clone the plugin source
```bash
cd /tmp && git clone --depth 1 https://github.com/willingning-coder/eagle-eye.git
```

### 2. Copy engine files into Hermes `agent/` directory
The plugin's `plugin.py` imports `agent.skill_retriever`. This means `skill_retriever.py` must be on `sys.path` inside the Hermes environment. The only reliable location is `/usr/local/lib/hermes-agent/agent/`.

```bash
sudo cp /tmp/eagle-eye/src/skill_retriever.py /usr/local/lib/hermes-agent/agent/
sudo cp /tmp/eagle-eye/src/skill_synonyms.yaml /usr/local/lib/hermes-agent/agent/
```

### 3. Copy plugin manifest into `plugins/eagle-eye/`
```bash
sudo cp /tmp/eagle-eye/src/plugin.py /usr/local/lib/hermes-agent/plugins/eagle-eye/__init__.py
sudo cp /tmp/eagle-eye/src/plugin.yaml /usr/local/lib/hermes-agent/plugins/eagle-eye/plugin.yaml
```

### 4. Install Python deps into Hermes venv (NOT user venv)
```bash
sudo /usr/local/lib/hermes-agent/venv/bin/pip install jieba sentence-transformers
```

### 5. Enable plugin in config
```bash
hermes config set plugins.enabled '["eagle-eye"]'
```

**Critical:** The config format is a flat array, NOT nested under `plugins.eagle_eye.enabled`. Setting the wrong key silently does nothing.

Verify with:
```bash
grep -A1 "plugins:" ~/.hermes/config.yaml
```
Expected:
```yaml
plugins:
  enabled: '["eagle-eye"]'
```

### 6. Customize hard triggers
Edit `/usr/local/lib/hermes-agent/agent/skill_retriever.py` around line 56. Replace the default `_HARD_TRIGGERS` list with your own skill mappings. The format is:
```python
("trigger_keyword", "skill-name"),
```

After editing, verify with:
```bash
/usr/local/lib/hermes-agent/venv/bin/python -c "
import sys; sys.path.insert(0, '/usr/local/lib/hermes-agent')
from agent.skill_retriever import get_skill_retriever
r = get_skill_retriever()
print('health check ->', r._hard_trigger('run health check'))
"
```

### 7. Restart gateway
```bash
systemctl --user restart hermes-gateway
```
Or wait for next natural restart.

## Verification

```bash
/usr/local/lib/hermes-agent/venv/bin/python -c "
import sys; sys.path.insert(0, '/usr/local/lib/hermes-agent')
from agent.skill_retriever import get_skill_retriever, _HARD_TRIGGERS
r = get_skill_retriever()
print(f'triggers={len(_HARD_TRIGGERS)}')
print('docker ->', r._hard_trigger('docker container'))
print('health ->', r._hard_trigger('health check'))
"
```

## Common Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| `ModuleNotFoundError: agent.skill_retriever` | File not in `agent/` dir, or sys.path wrong | Confirm `ls /usr/local/lib/hermes-agent/agent/skill_retriever.py` |
| `jieba not found` | Installed to user python, not Hermes venv | Use `/usr/local/lib/hermes-agent/venv/bin/pip install jieba` |
| Plugin not loading | Config key wrong format | Must be `plugins.enabled: ['eagle-eye']`, not `plugins.eagle_eye.enabled` |
| Triggers not matching | Skill name mismatch between trigger and actual skill dir name | Verify skill dir name under `~/.hermes/skills/<category>/` |
| `source .venv/bin/activate` blocked | Hermes execution guard on `source` | Use direct venv python path instead |
