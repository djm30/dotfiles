local M = {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  opts = {},
}

-- Need to install styled components plugin globally
-- npm i -g @styled/typescript-styled-plugin typescript-styled-plugin
M.config = function()
  require("typescript-tools").setup {
    on_attach = require("setup.config.lsp.handlers").setup,
    settings = {
      tsserver_plugins = {
        -- for TypeScript v4.9+
        "@styled/typescript-styled-plugin",
        -- or for older TypeScript versions
        -- "typescript-styled-plugin",
      },
    },
  }
end

-- Disabling typesscript tools
-- return M
return {}
