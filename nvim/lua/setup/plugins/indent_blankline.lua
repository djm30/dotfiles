local M = {
  "lukas-reineke/indent-blankline.nvim",
  priority = 1000,
  main = "ibl",
}

M.config = function()
  require("ibl").setup {
    indent = {
      char = "│",
      tab_char = "│",
    },
    scope = { enabled = true },
    exclude = {
      filetypes = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
      },
      buftypes = {
        "dashboard",
      },
    },
  }
end

return M
