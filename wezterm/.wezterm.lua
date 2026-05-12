-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.wsl_domains = {
    {
        name = 'WSL:Ubuntu',
        distribution = 'Ubuntu',
    },
}

config.default_domain = 'WSL:Ubuntu'

config.font = wezterm.font('JetBrainsMono NF', { weight = "Bold" })
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.window_background_opacity = 0.4
config.font_size = 14
config.color_scheme = 'Matrix (terminal.sexy)'

-- Finally, return the configuration to wezterm:
return config
