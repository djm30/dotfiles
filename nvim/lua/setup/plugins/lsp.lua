return {
  {
    -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "stevearc/conform.nvim",

      -- Additional lua configuration, makes nvim stuff amazing!
      { "folke/neodev.nvim", opts = {} },
    },
  },

  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    -- Need to install styled components plugin globally
    -- npm i -g @styled/typescript-styled-plugin typescript-styled-plugin
    config = function()
      require("typescript-tools").setup {
        on_attach = require("setup.config.lsp.handlers").on_attach,
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
