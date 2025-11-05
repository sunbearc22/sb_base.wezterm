# sb_base.wezterm

Apply a base wezterm configuration for two 1920x1080 screens in landscape mode, each dpi=96, placed side by side. In particular, once Wezterm is startup, its GUI window will:
- span across the entirety of both monitors and is resizable
- not resize when font size is changed
- show:
    - a customize title in the window titlebar with info on the active tab and pane.
    - integrated butttons and tab(s) at its bottom edge
    - a vertical scroll bar on its right edge
    - JetBrains Mono font that is 14pts in size with 1.3 line height
    - all round padding of 6 pixels
    - a blinking bar cursor in the active pane
- allow 3500 lines of scrollback per tab
- prioritize using the discrete GPU for rendering

NOTE: This plugin must be required first before requiring any other plugins in `wezterm.lua`.


## Usage

```lua
local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- Add these lines (to use plugin and its default options):
local repo = "https://github.com/sunbearc22/sb_base.wezterm.git"
wezterm.plugin.require(repo).apply_to_config(config, {})

return config
```

## Options

**Default options**

```lua
local repo = "https://github.com/sunbearc22/sb_base.wezterm.git"
wezterm.plugin.require(repo).apply_to_config(config,
  {
    offset_x = 0,         -- Number of pixels from top left corner of screen(s) in x-direction
    offset_y = 0,         -- Number of pixels from top left corner of screen(s) in the negative y-direction
    leader_key = "b",     -- Leader key for your WezTerm
    leader_mods = "ALT",  -- Leader mods for your WezTerm
  }
)
```
Change the value of these option fields to your preference.

## Key Binding

**Default key**

### Leader key
| Key Binding | Action |
| :----- | :------- |
| <kbd>ALT</kbd><kbd>e</kbd>  | Avtivate leader key |

## Update

Press <kbd>CTRL</kbd><kbd>SHIFT</kbd><kbd>L</kbd> and run `wezterm.plugin.update_all()`.

## Removal

1. Press <kbd>CTRL</kbd><kbd>SHIFT</kbd><kbd>L</kbd> and run `wezterm.plugin.list()`.
2. Delete the `"plugin_dir"` directory of this plugin.

