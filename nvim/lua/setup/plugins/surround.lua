local M = {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
}

M.config = function()
  require("nvim-surround").setup {}

  -- ys to add surround
  -- ds to delete surround
  -- cs to change surround
end

return M
