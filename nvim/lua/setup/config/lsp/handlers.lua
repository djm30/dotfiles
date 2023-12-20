local M = {}

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
  return
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)

M.setup = function()
  local signs = {

    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    virtual_text = true, -- disable virtual text
    signs = {
      active = signs, -- show signs
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end
local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }

  local function opts_with_desc(desc)
    return {
      noremap = opts.noremap,
      silent = opts.silent,
      desc = desc,
    }
  end

  local keymap = vim.api.nvim_buf_set_keymap

  keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts_with_desc "Go to declaration")
  keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts_with_desc "Go to definiton")
  keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts_with_desc "Show hover popup")
  keymap(bufnr, "n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts_with_desc "Go to implementation")
  keymap(bufnr, "n", "gr", "<cmd>Telescope lsp_references<CR>", opts_with_desc "Go to references")
  keymap(bufnr, "n", "<leader>cd", "<cmd>lua vim.diagnostic.open_float()<CR>", opts_with_desc "Open diagnostic float")
  --  keymap(bufnr, "n", "<leader>cf", "<cmd>lua vim.lsp.buf.format{ async = true }<cr>", opts_with_desc("Format with builtin LSP"))
  keymap(bufnr, "n", "<leader>cf", "<cmd>lua require('conform').format()<cr>", opts_with_desc "Format with builtin LSP")
  keymap(bufnr, "n", "<leader>cd", "<cmd>lua vim.diagnostic.open_float()<CR>", opts_with_desc "Open diagnostic float")
  keymap(bufnr, "n", "<leader>ci", "<cmd>LspInfo<cr>", opts_with_desc "Open LspInfo")
  keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts_with_desc "Run Code Action")
  keymap(
    bufnr,
    "n",
    "<leader>cj",
    "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>",
    opts_with_desc "Go to next diagnostic"
  )
  keymap(
    bufnr,
    "n",
    "<leader>ck",
    "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>",
    opts_with_desc "Go to prev diagnostic"
  )
  keymap(bufnr, "n", "<leader>cr", "<cmd>lua vim.lsp.buf.rename()<cr>", opts_with_desc "Rename symbol")
  keymap(bufnr, "n", "<leader>cs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts_with_desc "Signature Help")
  keymap(
    bufnr,
    "n",
    "<leader>cq",
    "<cmd>lua vim.diagnostic.setloclist()<CR>",
    opts_with_desc "Populates location list with diagnostics"
  )
end

M.on_attach = function(client, bufnr)
  if client.name == "tsserver" then
    client.server_capabilities.documentFormattingProvider = false
  end

  if client.name == "sumneko_lua" then
    client.server_capabilities.documentFormattingProvider = false
  end

  lsp_keymaps(bufnr)

  require("which-key").register {
    ["<leader>c"] = { name = "Code via LSP" },
  }

  local status_ok, illuminate = pcall(require, "illuminate")
  if not status_ok then
    return
  end
  illuminate.on_attach(client)
end

return M
