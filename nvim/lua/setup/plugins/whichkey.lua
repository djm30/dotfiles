local M = { "folke/which-key.nvim", opts = {} }

M.config = function()
  local wk = require "which-key"

  wk.register {
    ["<leader>f"] = { name = "Find" },
    ["<leader>s"] = { name = "Split" },
    ["<leader>t"] = { name = "Terminal" },
    ["<leader>c"] = { name = "Code via LSP" },
  }
end

return M
