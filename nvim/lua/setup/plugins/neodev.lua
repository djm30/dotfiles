local M = { "folke/neodev.nvim", opts = {} }

M.config = function()
  require("neodev").setup()
end

return M
