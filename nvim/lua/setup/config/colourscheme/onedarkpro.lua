local style = "onedark_vivid"

local helper = require "onedarkpro.helpers"
local colours = helper.get_colors()

local darkbg = helper.darken("bg", 1, "onedark_vivid")
local darkerbg = helper.darken("bg", 3, "onedark_vivid")

print(colours)
local custom_highlights = {
  LeapBackdrop = { fg = colours.gray },
  TelescopeNormal = { bg = darkbg },
  TelescopeBorder = { bg = darkbg, fg = darkbg },
  TelescopePromptBorder = { bg = darkerbg, fg = darkerbg },
  TelescopePromptCounter = { fg = colours.light_gray },
  TelescopePromptNormal = { fg = colours.fg, bg = darkerbg },
  TelescopePromptPrefix = { fg = colours.blue, bg = darkerbg },
  TelescopePromptTitle = { fg = darkbg, bg = colours.blue },
  TelescopePreviewTitle = { fg = darkbg, bg = colours.blue },
  TelescopePreviewBorder = { bg = darkbg, fg = darkbg },
  TelescopePreviewNormal = { bg = darkbg, fg = darkbg },
  TelescopeResultsTitle = { fg = darkbg, bg = colours.red },
  TelescopeMatching = { fg = colours.yellow },
  TelescopeSelection = { bg = darkbg },
  TelescopeSelectionCaret = { fg = colours.red },
  TelescopeResultsNormal = { bg = darkbg },
  TelescopeResultsBorder = { bg = darkbg, fg = darkbg },
  NavicIconsFile = { fg = colours.blue, bg = darkbg },
  IncSearch = { fg = darkbg, bg = "#BA78D7" },
  Pmenu = { bg = "none" },
  NoiceCmdlinePopup = { bg = darkbg, fg = colours.light_gray },
  NoiceCmdlinePopupTitle = { fg = darkbg, bg = colours.blue },
  NoiceCmdlinePopupBorder = { bg = darkbg, fg = darkbg },
  WhichKeyFloat = { bg = darkbg, fg = "none" },
  FloatBorder = { bg = "none", fg = "none" },
  NormalFloat = { bg = "none", fg = "none" },
  DashboardHeader = { fg = colours.purple },
  DashboardFooter = { fg = colours.blue },
  NeoTreeNormal = { bg = colours.darkbg },
}

require("onedarkpro").setup {
  options = {
    transparency = false,
  },
  highlights = custom_highlights,
}

vim.cmd("colorscheme " .. style)
