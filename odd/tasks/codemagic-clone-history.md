# Fix Codemagic release clone history

## Goal

Allow semantic-tag release builds to clone successfully with complete Git history for release-note generation.

## Incident

The `v1.0.0` Codemagic build failed before scripts ran because `CM_CLONE_DEPTH: 0` produced `git clone --depth 0`, which Git rejects because clone depth must be positive.

## Decision

- Keep the published `v1.0.0` tag immutable.
- Replace `CM_CLONE_DEPTH: 0` with Codemagic's documented `CM_CLONE_UNSHALLOW: true` setting.
- Deliver the fix through issue, PR, CI, and merge before creating a new `v1.0.1` tag.
- Creating and pushing `v1.0.1` remains a separate explicit publication authorization.

## Allowed edit surfaces

- `codemagic.yaml`
- `odd/tasks/codemagic-clone-history.md`

## Tasks

- [x] CMH-1 — Add a failing structural assertion for release checkout configuration.
- [x] CMH-2 — Configure full-history release checkout using `CM_CLONE_UNSHALLOW`.
- [x] CMH-3 — Validate YAML and obtain independent review.

## Verification evidence

### CMH-1 — RED

Ran the following structural assertion before changing `codemagic.yaml`. It parses YAML with PyYAML and checks both release checkout requirements:

```bash
python3 -B - <<'PY'
from pathlib import Path
import yaml

config = yaml.safe_load(Path('codemagic.yaml').read_text())
variables = config['workflows']['android-play-release']['environment']['vars']
errors = []
if 'CM_CLONE_DEPTH' in variables:
    errors.append(f"CM_CLONE_DEPTH must be absent (found {variables['CM_CLONE_DEPTH']!r})")
if variables.get('CM_CLONE_UNSHALLOW') is not True:
    errors.append(f"CM_CLONE_UNSHALLOW must be true (found {variables.get('CM_CLONE_UNSHALLOW')!r})")
if errors:
    print('FAIL: android-play-release: ' + '; '.join(errors))
    raise SystemExit(1)
print('PASS: android-play-release omits CM_CLONE_DEPTH and sets CM_CLONE_UNSHALLOW to true')
PY
```

Observed output (exit code 1):

```text
FAIL: android-play-release: CM_CLONE_DEPTH must be absent (found 0); CM_CLONE_UNSHALLOW must be true (found None)
```

Transition: CMH-1 pending → complete after the intended failure was observed; CMH-2 pending → in progress.

### CMH-2 — GREEN

Changed only `android-play-release.environment.vars`: replaced `CM_CLONE_DEPTH: 0` with `CM_CLONE_UNSHALLOW: true`. This uses the documented full-history clone option rather than passing an invalid depth of zero to Git.

Reran the exact `python3 -B - <<'PY'` assertion above unchanged. Observed output (exit code 0):

```text
PASS: android-play-release omits CM_CLONE_DEPTH and sets CM_CLONE_UNSHALLOW to true
```

Transition: CMH-2 in progress → complete after the same structural assertion passed.

### CMH-3 — Local validation and independent review complete

Ran this additional YAML parsing and scope-preservation assertion:

```bash
python3 -B - <<'PY'
from pathlib import Path
import subprocess
import yaml

before_text = subprocess.check_output(['git', 'show', 'HEAD:codemagic.yaml'], text=True)
after_text = Path('codemagic.yaml').read_text()
before = yaml.safe_load(before_text)
after = yaml.safe_load(after_text)
assert after_text == before_text.replace('        CM_CLONE_DEPTH: 0\n', '        CM_CLONE_UNSHALLOW: true\n', 1), 'Unexpected configuration text changes'
for name in ('android-workflow', 'ios-workflow'):
    assert after['workflows'][name] == before['workflows'][name], f'{name} changed'
print('PASS: YAML parses; only the release checkout setting changed; normal Android and iOS workflows are unchanged')
PY
```

Observed output (exit code 0):

```text
PASS: YAML parses; only the release checkout setting changed; normal Android and iOS workflows are unchanged
```

Ran `git diff --check`: exit code 0, no output.

Independent review: PASS with no HIGH or MEDIUM findings. The reviewer reran the structural assertion, scope-preservation assertion, and `git diff --check`; all passed, and pre/post repository status was identical.

A live Codemagic checkout was not run; these checks validate configuration structure, not hosted execution. The original `v1.0.0` tag remains unchanged, and any later `v1.0.1` publication requires separate explicit authorization. No push, tag mutation, PR, merge, or publication was performed. Unrelated worktree changes were preserved.

## Commit evidence

Pending transaction-controller Conventional Commit creation.
