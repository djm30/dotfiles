-- create a .lua file with the matching server name in the settings folder to setup extra options
local servers = {
  "lua_ls",
  "cssls",
  "html",
  "pyright",
  "bashls",
  "jsonls",
  "yamlls",
  "rust_analyzer",
  "svelte",
  "marksman",
  "emmet_language_server",
  "clangd",
}

local formatters = {
  "prettier",
  "prettierd",
  "stylua",
  "isort",
  "black",
}

local linters = {
  "eslint_d",
}

local debugAdapters = {
  "js-debug-adapter",
}

-- Install formatters, linters and debug adapters (LSP servers are handled by mason-lspconfig)
vim.api.nvim_create_user_command("InstallTools", function()
  vim.cmd("MasonInstall " .. table.concat(vim.list_extend(vim.list_extend(vim.deepcopy(formatters), linters), debugAdapters), " "))
end, { nargs = 0 })

require("mason").setup {
  ui = {
    border = "none",
    icons = {
      package_installed = "◍",
      package_pending = "◍",
      package_uninstalled = "◍",
    },
  },
  max_concurrent_installers = 4,
}

require("mason-lspconfig").setup { ensure_installed = servers }

local handlers = require "setup.config.lsp.handlers"
local lspconfig = require "lspconfig"

for _, server in ipairs(servers) do
  local opts = { on_attach = handlers.on_attach, capabilities = handlers.capabilities }

  -- Optional per-server overrides in lsp/settings/<server>.lua
  local ok, server_opts = pcall(require, "setup.config.lsp.settings." .. server)
  if ok then
    opts = vim.tbl_deep_extend("force", server_opts, opts)
  end

  lspconfig[server].setup(opts)
end
