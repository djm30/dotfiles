local wezterm = require("wezterm")

local config = wezterm.config_builder()
local act = wezterm.action

config.color_scheme_dirs = { "./schemes" }

local function rgba(r, g, b, a)
	return "rgba(" .. r .. ", " .. g .. ", " .. b .. ", " .. a .. ")"
end

config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMono Nerd Font", weight = "Medium", scale = 1.2 },
	{ family = "MesloLGS NF", scale = 1.2 },
})

-- config.color_scheme = "One Dark (Gogh)"
-- config.color_scheme = "Dracula+"
-- wezterm.color.load_scheme("$DOTFILES/wezterm/onedarkpro.toml")

config.color_scheme = "OneDarkPro"

config.force_reverse_video_cursor = false

local opacity = 0.95
local tab_bar_colour = rgba(30, 33, 39, 0.96)
local active_tab_colour = rgba(97, 175, 239, 0.96)
local inactive_tab_colour = rgba(30, 33, 39, 0.96)

config.window_close_confirmation = "AlwaysPrompt"
config.window_decorations = "RESIZE"
config.window_background_opacity = opacity
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false

config.colors = {
	cursor_bg = "#BA78D7",
	cursor_fg = "#FFFFFF",
	tab_bar = {
		background = tab_bar_colour,
		active_tab = {
			bg_color = active_tab_colour,
			fg_color = "#ffffff",
		},

		inactive_tab = {
			bg_color = inactive_tab_colour,
			fg_color = "#808080",
		},
	},
}

-- Leader is CTRL A
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- Send C-a when pressing C-a twice
	{ key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
	{ key = "c", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = "phys:Space", mods = "LEADER", action = act.ActivateCommandPalette },

	-- Pane keybindings
	{ key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "q", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "o", mods = "LEADER", action = act.RotatePanes("Clockwise") },
	-- Activates pane resize key table
	{
		key = "r",
		mods = "LEADER",
		action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }),
	},

	-- Tab keybindings
	{ key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "n", mods = "LEADER", action = act.ShowTabNavigator },
	{
		key = "e",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Renaming Tab Title...:" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	-- Key table for moving tabs around
	{ key = "m", mods = "LEADER", action = act.ActivateKeyTable({ name = "move_tab", one_shot = false }) },
	-- Or shortcuts to move tab w/o move_tab table. SHIFT is for when caps lock is on
	{ key = "{", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },

	-- Lastly, workspace
	{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
}
-- I can use the tab navigator (LDR t), but I also want to quickly navigate tabs with index
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
end

config.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
	move_tab = {
		{ key = "h", action = act.MoveTabRelative(-1) },
		{ key = "j", action = act.MoveTabRelative(-1) },
		{ key = "k", action = act.MoveTabRelative(1) },
		{ key = "l", action = act.MoveTabRelative(1) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
}

-- Makes left option work as intended if true
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

return config
