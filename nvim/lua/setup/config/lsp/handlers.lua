local M = {}

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
  return
end

local border = "rounded"

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
    virtual_text = true,
    signs = {
      active = signs, -- show signs
    },
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = border,
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = border,
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = border,
  })
end

local function lsp_keymaps(bufnr)
  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
  end
  local function telescope(picker, opts)
    return function()
      require("telescope.builtin")[picker](opts or {})
    end
  end

  map("gD", vim.lsp.buf.declaration, "Go to declaration")
  map("gd", vim.lsp.buf.definition, "Go to definition")
  map("K", vim.lsp.buf.hover, "Show hover information")
  map("gI", vim.lsp.buf.implementation, "Go to implementation")
  map("gt", vim.lsp.buf.type_definition, "Go to type definition")
  map("gr", telescope("lsp_references", { layout_strategy = "center" }), "Go to references")
  map("gf", telescope("diagnostics", { layout_strategy = "center", bufnr = 0 }), "Find diagnostics")
  map("gq", function()
    require("conform").format { bufnr = bufnr }
  end, "Format")

  map("<leader>cd", function()
    vim.diagnostic.open_float { border = "single", source = "always" }
  end, "Show line diagnostics")
  map("<leader>ci", "<cmd>LspInfo<cr>", "Open LSP info")
  map("<leader>ca", vim.lsp.buf.code_action, "Show code actions")
  map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
  map("<leader>cs", vim.lsp.buf.signature_help, "Show signature help")
  map("<leader>cq", vim.diagnostic.setloclist, "Diagnostics to location list")
  map("<LocalLeader>p", function()
    require("nvim-treesitter.textobjects.lsp_interop").peek_definition_code "@block.outer"
  end, "Peek definition")
  map("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
  map("]d", vim.diagnostic.goto_next, "Next diagnostic")
end

-- Servers whose formatting is handled by conform instead
local no_format = { ts_ls = true, tsserver = true, ["typescript-tools"] = true, lua_ls = true }

M.on_attach = function(client, bufnr)
  if no_format[client.name] then
    client.server_capabilities.documentFormattingProvider = false
  end

  lsp_keymaps(bufnr)

  local ok, illuminate = pcall(require, "illuminate")
  if ok then
    illuminate.on_attach(client)
  end
end

return M
