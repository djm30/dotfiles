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
  local t = require "legendary.toolbox"

  require("legendary").keymaps {
    itemgroup = "LSP",
    icon = "",
    description = "LSP related functionality",
    keymaps = {
      -- Your existing keymaps converted to legendary format
      {
        "gD",
        vim.lsp.buf.declaration,
        description = "Go to declaration",
        opts = { buffer = bufnr },
      },
      {
        "gd",
        vim.lsp.buf.definition,
        description = "Go to definition",
        opts = { buffer = bufnr },
      },
      {
        "K",
        vim.lsp.buf.hover,
        description = "Show hover information",
        opts = { buffer = bufnr },
      },
      {
        "gI",
        vim.lsp.buf.implementation,
        description = "Go to implementation",
        opts = { buffer = bufnr },
      },
      {
        "gr",
        t.lazy_required_fn("telescope.builtin", "lsp_references", {
          layout_strategy = "center",
        }),
        description = "Go to references",
        opts = { buffer = bufnr },
      },
      {
        "<leader>cd",
        function()
          vim.diagnostic.open_float(0, { border = "single", source = "always" })
        end,
        description = "Show line diagnostics",
        opts = { buffer = bufnr },
      },
      {
        "<leader>ci",
        "<cmd>LspInfo<cr>",
        description = "Open LSP info",
        opts = { buffer = bufnr },
      },
      {
        "<leader>ca",
        vim.lsp.buf.code_action,
        description = "Show code actions",
        opts = { buffer = bufnr },
      },
      {
        "<leader>cr",
        vim.lsp.buf.rename,
        description = "Rename symbol",
        opts = { buffer = bufnr },
      },
      {
        "<leader>cs",
        vim.lsp.buf.signature_help,
        description = "Show signature help",
        opts = { buffer = bufnr },
      },
      {
        "<leader>cq",
        vim.diagnostic.setloclist,
        description = "Populate location list with diagnostics",
        opts = { buffer = bufnr },
      },

      -- Additional useful mappings from the original list
      {
        "gf",
        t.lazy_required_fn("telescope.builtin", "diagnostics", {
          layout_strategy = "center",
          bufnr = 0,
        }),
        description = "Find diagnostics",
        opts = { noremap = true },
      },
      {
        "gt",
        vim.lsp.buf.type_definition,
        description = "Go to type definition",
        opts = { buffer = bufnr },
      },
      {
        "gq",
        function()
          require("conform").format { bufnr = bufnr }
        end,
        description = "Format",
        opts = { buffer = bufnr },
      },
      {
        "<LocalLeader>p",
        t.lazy_required_fn("nvim-treesitter.textobjects.lsp_interop", "peek_definition_code", "@block.outer"),
        description = "Peek definition",
        opts = { buffer = bufnr },
      },
      {
        "[d",
        vim.diagnostic.goto_prev,
        description = "Go to previous diagnostic item",
        opts = { buffer = bufnr },
      },
      {
        "]d",
        vim.diagnostic.goto_next,
        description = "Go to next diagnostic item",
        opts = { buffer = bufnr },
      },
    },
  }
end

M.on_attach = function(client, bufnr)
  if client.name == "tsserver" then
    client.server_capabilities.documentFormattingProvider = false
  end

  if client.name == "sumneko_lua" then
    client.server_capabilities.documentFormattingProvider = false
  end

  -- if client.name == "svelte" then
  --   vim.api.nvim_create_autocmd("BufWritePost", {
  --     pattern = { "*.js", "*.ts" },
  --     callback = function(ctx)
  --       client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
  --     end,
  --   })
  --
  --   vim.api.nvim_create_autocmd({ "BufWrite" }, {
  --     pattern = { "+page.server.ts", "+page.ts", "+layout.server.ts", "+layout.ts" },
  --     command = "LspRestart svelte",
  --   })
  -- end

  lsp_keymaps(bufnr)

  local status_ok, illuminate = pcall(require, "illuminate")
  if not status_ok then
    return
  end
  illuminate.on_attach(client)
end

return M
