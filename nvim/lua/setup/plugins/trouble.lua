return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {},
  config = function()
    -- Lua
    local opts_with_desc = require("setup.config.util").opts_with_desc
    vim.keymap.set("n", "<leader>dx", function()
      require("trouble").toggle()
    end, opts_with_desc "Toggle diagnostics")
    vim.keymap.set("n", "<leader>dw", function()
      require("trouble").toggle "workspace_diagnostics"
    end, opts_with_desc "Toggle workspace diagnostics")
    vim.keymap.set("n", "<leader>dd", function()
      require("trouble").toggle "document_diagnostics"
    end, opts_with_desc "Toggle document diagnostics")
    vim.keymap.set("n", "<leader>dq", function()
      require("trouble").toggle "quickfix"
    end, opts_with_desc "Toggle quickfix list")
    vim.keymap.set("n", "<leader>dl", function()
      require("trouble").toggle "loclist"
    end, opts_with_desc "Toggle local list?")
    vim.keymap.set("n", "gR", function()
      require("trouble").toggle "lsp_references"
    end, opts_with_desc "Toggle trouble lsp references")
  end,
}
