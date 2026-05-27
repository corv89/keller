# keller

A browsable, annotatable overview of your Homebrew-installed CLI tools.

Solves the "I `brew install`ed something months ago and now I can't remember what it's called or what it does" problem.

## Features

- Two-panel TUI: formula list on the left, details on the right
- Default view shows only explicitly installed formulae (filters out transitive deps)
- Personal annotations: notes, tags, example commands per formula
- Live substring filter across name, description, tags, and notes
- Cached brew metadata (1-hour TTL) for fast startup
- `keller edit <name>` for scripting/quick annotation edits

## Requirements

- macOS 14+
- Homebrew
- Swift 6.0+

## Install

```bash
git clone https://github.com/user/keller.git
cd keller
swift build -c release
ln -s $(pwd)/.build/release/keller /usr/local/bin/keller
```

## Usage

```
keller              Launch the TUI (default)
keller edit <name>  Open $EDITOR on one formula's annotation
keller refresh      Force rebuild the brew metadata cache
```

## Keybindings

| Control | Action |
|---|---|
| Arrow Up/Down | Navigate formula list |
| Arrow Left/Right | Move between panels and action bar |
| Enter | Activate focused button/control |
| Filter field | Type query, Enter to apply |
| Toggle Deps | Show/hide transitive dependencies |
| Edit | Open $EDITOR for selected annotation |
| Refresh | Re-fetch brew metadata |
| Clear Filter | Remove active filter |
| Help | Toggle keybinding reference |
| Quit / Ctrl-C | Exit keller |

## Annotation format

Annotations are stored in `~/.config/keller/annotations.json`. When editing via the TUI or `keller edit`, a temporary markdown file with YAML front-matter is opened:

```markdown
---
tags: [cli, network]
examples:
  - "curl -s https://example.com"
---

Your notes here.
```

## File locations

| File | Path |
|---|---|
| Annotations | `~/.config/keller/annotations.json` |
| Cache | `~/.cache/keller/brew-snapshot.json` |

Respects `XDG_CONFIG_HOME` and `XDG_CACHE_HOME` if set.

## Build from source

```bash
swift build          # debug
swift build -c release  # optimized
swift test           # run tests
```

## License

MIT
