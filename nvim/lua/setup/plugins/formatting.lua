local M = {
  "stevearc/conform.nvim",
  opts = {},
}

M.config = function()
  require("conform").setup {
    formatters_by_ft = {
      lua = { "stylua" },
      -- Conform will run multiple formatters sequentially
      python = { "isort", "black" },
      -- Use a sub-list to run only the first available formatter
      javascript = { { "prettierd", "prettier", "eslint_d" } },
      typescript = { { "prettierd", "prettier", "eslint_d" } },
      typescriptreact = { { "prettierd", "prettier", "eslint_d" } },
      javascriptreact = { { "prettierd", "prettier", "eslint_d" } },
      json = { "prettierd", "prettier" },
    },

    format_on_save = {
      -- These options will be passed to conform.format()
      timeout_ms = 500,
      lsp_fallback = true,
    },
  }
end

function FORMAT()
  require("conform").format({ async = true, lsp_fallback = true }, function(err)
    if not err then
      if vim.startswith(vim.api.nvim_get_mode().mode:lower(), "v") then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
      end
    end
  end)
end

return M
