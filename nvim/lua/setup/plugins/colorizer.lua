local M = {
  "NvChad/nvim-colorizer.lua",
}

M.config = function()
  require("colorizer").setup()
end

return M
