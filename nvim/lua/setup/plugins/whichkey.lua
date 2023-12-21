local M = { "folke/which-key.nvim", opts = {} }

M.config = function()
  local wk = require "which-key"

  wk.register {
    ["<leader>f"] = { name = "Find" },
    ["<leader>s"] = { name = "Split" },
    ["<leader>t"] = { name = "Terminal" },
    ["<leader>g"] = {
      name = "Git",
      g = { "Toggle LazyGit" },
      t = { name = "Toggle...", b = { "Show current line blame" }, d = { "Show deletions" } },
      d = "Show diff",
      b = "Show current line blame info",
    },
    ["<leader>x"] = { name = "Exit" },
    ["<leader>c"] = { name = "Code" },
  }
end

return M
