local M = { "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons" }

M.config = function()
  require("bufferline").setup {
    options = {
      diagnostics = "nvim_lsp",
      show_buffer_close_icons = false,
    },
    highlights = {
      buffer_selected = {
        bg = "#282c34",
      },
    },
  }
end

return M
