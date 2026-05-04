-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.wsl_domains = {
    {
        name = 'Ubuntu',
        distribution = 'Ubuntu',
    },
}

config.font = wezterm.font('JetBrains Mono', { weight = "Bold" })
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.window_background_opacity = 0.4
config.font_size = 12
config.color_scheme = 'Matrix (terminal.sexy)'

-- Finally, return the configuration to wezterm:
return config
