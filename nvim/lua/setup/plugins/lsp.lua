return {
  {
    -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "stevearc/conform.nvim",

    },
  },

  {
    -- Neovim Lua API completion/types for this config (replaces neodev)
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
    },
  },

  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    -- Need to install styled components plugin globally
    -- npm i -g @styled/typescript-styled-plugin typescript-styled-plugin
    config = function()
      require("typescript-tools").setup {
        capabilities = require("setup.config.lsp.handlers").capabilities,
        settings = {
          tsserver_plugins = {
            -- for TypeScript v4.9+
            "@styled/typescript-styled-plugin",
            -- or for older TypeScript versions
            -- "typescript-styled-plugin",
          },
        },
      }
    end,
  },
}
