# hermes-check.sh Silent Failure Pattern

## Symptom
`hermes-check.sh` reports warnings on:
- `terminal.cwd not ...`
- `honcho not active in dump`
- `curator not reporting ENABLED`

All three checks fail simultaneously despite config being correct.

## Root cause
The script hardcodes the Hermes CLI path:
```bash
HBIN="/home/khuchinque/.local/bin/hermes"
```
When Hermes is installed system-wide (e.g. `/usr/local/bin/hermes`), this path does not exist. The `config show`, `dump`, and `curator status` invocations silently fail (exit 127 or exit 1), triggering the `warn` branch every time. These are **false positives**.

## Reproduction
```bash
# check where hermes actually lives
which hermes          # -> /usr/local/bin/hermes
ls ~/.local/bin/hermes  # -> No such file
bash /home/khuchinque/hermes-check.sh  # -> 3 warnings
```

## Fix
In `hermes-check.sh`, replace the hardcoded path with dynamic resolution:
```bash
HBIN="$(which hermes 2>/dev/null || echo /usr/local/bin/hermes)"
```

## Verification after fix
```bash
bash /home/khuchinque/hermes-check.sh
# Expected: pass:22 warn:0 fail:0
```

## Related
- Owner install preference: Hermes lives under `/home/khuchinque/.hermes`, but the CLI binary is at `/usr/local/bin/hermes` (system-wide install).
- Version checked: Hermes v0.18.0 (2026.7.1)
