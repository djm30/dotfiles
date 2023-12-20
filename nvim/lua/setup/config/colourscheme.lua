-- black
-- bg0
-- bg1
-- bg2
-- bg3
-- bg_d
-- bg_blue
-- bg_yellow
-- fg
-- purple
-- green
-- orange
-- blue
-- yellow
-- cyan
-- red
-- grey
-- light_grey
-- dark_cyan
-- dark_red
-- dark_yellow
-- dark_purple
-- diff_add
-- diff_delete
-- diff_change
-- diff_text

local style = "darker"

local colours = require("onedark.palette")[style]

local telescope_custom_highlights = {
  LeapBackdrop = { fg = colours.grey },
  TelescopeNormal = { bg = colours.bg0 },
  TelescopeBorder = { bg = colours.bg0, fg = colours.bg0 },
  TelescopePromptBorder = { bg = colours.bg1, fg = colours.bg1 },
  TelescopePromptCounter = { fg = colours.light_grey },
  TelescopePromptNormal = { fg = colours.fg, bg = colours.bg1 },
  TelescopePromptPrefix = { fg = colours.blue, bg = colours.bg1 },
  TelescopePromptTitle = { fg = colours.bg0, bg = colours.blue },
  TelescopePreviewTitle = { fg = colours.bg0, bg = colours.blue },
  TelescopePreviewBorder = { bg = colours.bg0, fg = colours.bg0 },
  TelescopePreviewNormal = { bg = colours.bg0, fg = colours.bg0 },
  TelescopeResultsTitle = { fg = colours.bg0, bg = colours.red },
  TelescopeMatching = { fg = colours.yellow },
  TelescopeSelection = { bg = colours.bg0 },
  TelescopeSelectionCaret = { fg = colours.red },
  TelescopeResultsNormal = { bg = colours.bg0 },
  TelescopeResultsBorder = { bg = colours.bg0, fg = colours.bg0 },
  NavicIconsFile = { fg = colours.blue, bg = colours.bg0 },
}

require("onedark").setup {
  style = style,
  transparent = true,

  diagnostics = {
    darker = true, -- darker colors for diagnostic
    undercurl = true, -- use undercurl instead of underline for diagnostics
    background = true, -- use background color for virtual text
  },

  highlights = telescope_custom_highlights,
}
-- Colourscheme
vim.cmd.colorscheme "onedark"
