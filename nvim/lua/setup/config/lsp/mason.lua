-- create a .lua file with the matching server name in the settings folder to setup extra options
local servers = {
  "lua_ls",
  "cssls",
  "html",
  "tsserver",
  "pyright",
  "bashls",
  "jsonls",
  "yamlls",
  "rust_analyzer",
  "svelte",
  "marksman",
  "emmet_language_server",
  -- "clangd",
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

local function install_tools()
  local function install_all(requirements)
    for _, requirement in ipairs(requirements) do
      vim.cmd("MasonInstall " .. requirement)
    end
  end

  install_all(formatters)
  install_all(linters)
  install_all(debugAdapters)
end

vim.api.nvim_create_user_command("InstallTools", install_tools, {nargs = 0})

local settings = {
  ui = {
    border = "none",
    icons = {
      package_installed = "◍",
      package_pending = "◍",
      package_uninstalled = "◍",
    },
  },
  log_level = vim.log.levels.INFO,
  max_concurrent_installers = 4,
}

require("mason").setup(settings)
require("mason-lspconfig").setup {
  ensure_installed = servers,
  automatic_installation = true,
}

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

local opts = {}

for _, server in pairs(servers) do
  opts = {
    on_attach = require("setup.config.lsp.handlers").on_attach,
    capabilities = require("setup.config.lsp.handlers").capabilities,
  }

  server = vim.split(server, "@")[1]
  -- Adding additional language server options
  local require_ok, conf_opts = pcall(require, "setup.config.lsp.settings." .. server)
  if require_ok then
    opts = vim.tbl_deep_extend("force", conf_opts, opts)
    if server == "svelte" then
      print(opts)
    end
  end

  lspconfig[server].setup(opts)
end
