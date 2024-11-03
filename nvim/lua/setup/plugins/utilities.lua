return {

  {
    "mrjones2014/legendary.nvim", -- A command palette for keymaps, commands and autocmds
    priority = 10000,
    lazy = false,
    dependencies = "kkharji/sqlite.lua",
    init = function()
      require("legendary").keymaps {
        {
          "<C-p>",
          require("legendary").find,
          hide = true,
          description = "Open Legendary",
          mode = { "n", "v" },
        },
      }
    end,
    config = function()
      require("legendary").setup {
        select_prompt = "Legendary",
        include_builtin = false,
        extensions = {
          codecompanion = false,
          lazy_nvim = false,
          which_key = false,
        },
        -- Load these with the plugin to ensure they are loaded before any Neovim events
        autocmds = require "setup.config.autocmds",
      }
    end,
  },

  {
    "folke/neodev.nvim",
    opts = {},
    config = function()
      require("neodev").setup()
    end,
  },
  "nvim-lua/plenary.nvim", -- Required dependency for many plugins. Super useful Lua functions

  {
    "kevinhwang91/nvim-bqf", -- Better quickfix window,
    ft = "qf",
  },

  {
    "famiu/bufdelete.nvim", -- Easily close buffers whilst preserving your window layouts
    cmd = "Bdelete",
    init = function()
      require("legendary").keymaps {
        { "<C-c>", "<cmd>Bdelete<CR>", hide = true, description = "Close Buffer" }, -- bufdelete.nvim
        { "<Tab>", "<cmd>bnext<CR>", hide = true, description = "Next buffer", opts = { noremap = false } }, -- Heirline.nvim
        {
          "<S-Tab>",
          "<cmd>bprev<CR>",
          hide = true,
          description = "Previous buffer",
          opts = { noremap = false },
        }, -- Heirline.nvim
      }
    end,
  },

  "romainl/vim-cool",
}
