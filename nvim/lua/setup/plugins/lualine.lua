local M = {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
}

M.config = function()
  require("lualine").setup {
    options = {
      theme = "onedark",
    },
  }
end

return M
