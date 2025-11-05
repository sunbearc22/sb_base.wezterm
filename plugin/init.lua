--[[
This Plugin does the following:
- Apply a base wezterm configuration for two 1920x1080 screens in landscape mode, each dpi=96,
  placed side by side.
- Particularly, once Wezterm is startup, its GUI window will:
  - span across the entirety of both monitors and is resizable
  - not resize when font size is changed
  - show
    - a customize title in the window titlebar with info on the active tab and pane.
    - integrated butttons and tab(s) at its bottom edge
    - a vertical scroll bar on its right edge
    - JetBrains Mono font that is 14pts in size with 1.3 line height
    - all round padding of 6 pixels
    - a blinking bar cursor in the active pane
  - allow 3500 lines of scrollback per tab
  - prioritize using the discrete GPU for rendering

NOTE: This plugin must be required first before requiring any other plugins in wezterm.lua.

Written by: sunbearc22
Tested on: Ubuntu 24.04.3, wezterm 20251025-070338-b6e75fd7
]]
local wezterm = require("wezterm")

-- Full screen cell dimensions for two 1920x1080 screens in landscape mode, each dpi=96,
-- placed side by side.
local all_screens_rows = 30  -- no. of roll cells
local all_screens_cols = 348 -- no. of col cells

local M = {}

---@param config unknown
---@param opts {
---offset_x: number?,
---offset_y: number?,
---leader_key: string?,
---leader_mods: string?}
function M.apply_to_config(config, opts)
  local offset_x = opts.offset_x or 0
  local offset_y = opts.offset_y or 0
  local leader_key = opts.leader_key or "e"
  local leader_mods = opts.leader_mods or "ALT"

  wezterm.GLOBAL.window_start_offset_x = offset_x
  wezterm.GLOBAL.window_start_offset_y = offset_y

  -- Define LEADER key and mods
  -- timeout_milliseconds defaults to 1000 and can be omitted
  config.leader = {
    key = leader_key,
    mods = leader_mods,
    timeout_milliseconds = 2000,
  }

  -- Make wezterm GUI appear from the top left corner of the screen(s)
  local start_point = string.format("%d,%d", offset_x, offset_y)
  config.default_gui_startup_args = { "start", "--position", start_point }

  -- New window width and height to fill 2 screens.
  config.initial_cols = all_screens_cols
  config.initial_rows = all_screens_rows

  -- Window size should not change when font size is changed
  config.adjust_window_size_when_changing_font_size = false

  -- Window decoration
  config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

  -- Tab bar at the bottom
  config.tab_bar_at_bottom = true

  -- Set Font (use default Jet Brain Mono)
  config.font_size = 14
  config.line_height = 1.3

  -- Increase scrollback to retain per tab to
  config.scrollback_lines = 3500

  -- Enable scroll_bar
  config.enable_scroll_bar = true

  -- Define padding in terms of no. of pixels
  -- This define the space between the window border to the cells border
  -- that is within the window and is unrelated to opts.offset_x and
  -- opts.offset_y.
  config.window_padding = {
    left = 6,
    right = 6, -- controls the scroll-bar's width
    top = 6,
    bottom = 6,
  }

  -- Set Window Title
  -- Table to store the number of cell rows and colums for each pane ID
  local panes_rows_cols = {}

  wezterm.on("update-status", function(window, pane)
    local dimensions = pane:get_dimensions()
    local cols = dimensions and dimensions.cols or "N/A"
    local rows = dimensions and dimensions.viewport_rows or "N/A"

    -- Create a size text with window size
    local size_text = string.format("%s rolls, %s cols", rows, cols)

    -- Store size_text in the table with pane ID as the key
    panes_rows_cols[pane:pane_id()] = size_text
  end)

  wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
    local zoomed = " "
    local id = tab.active_pane.pane_id
    if tab.active_pane.is_zoomed then
      zoomed = "[Z] "
    end
    local index = ""
    if #tabs > 1 then
      index = string.format("[%d/%d] ", tab.tab_index + 1, #tabs)
    end
    -- Retrieve the size_text for the current window using pane ID
    local size_text = panes_rows_cols[id] or ""
    return "::WEZTERM::  "
        .. zoomed
        .. "Active Tab: " .. index .. tab.active_pane.title .. "  Active Pane ID:" .. id .. " size(" .. size_text .. ")"
  end)

  -- Change cursor to BlinkingBar and control bar thickness and blinking behaviour
  config.default_cursor_style = "BlinkingBar"
  config.cursor_thickness = "2px"
  config.animation_fps = 20
  config.cursor_blink_ease_in = "EaseIn"
  config.cursor_blink_ease_out = "EaseOut"
  config.cursor_blink_rate = 1000

  -- Prioritize the use of the integrated GPU over discrete GPU as renderer
  -- for wezterm since it is often unused.
  local gpus = wezterm.gui.enumerate_gpus()
  local has_integrated_gpu = false
  local has_discrete_gpu = false
  for _, gpu in ipairs(gpus) do
    if gpu.type == "Integrated" then
      has_integrated_gpu = true
    elseif gpu.type == "Discrete" then
      has_discrete_gpu = true
    end
  end
  if has_discrete_gpu then
    config.webgpu_power_preference = "HighPerformance" -- use the discrete GPU
    wezterm.log_info("[BASE] Using Discrete GPU.")
  elseif has_integrated_gpu then
    config.webgpu_power_preference = "LowPower" -- use the integrated GPU
    wezterm.log_info("[BASE] Using Integrated GPU.")
  end
end

return M
