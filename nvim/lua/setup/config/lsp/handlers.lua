local M = {}

M.capabilities = require("blink.cmp").get_lsp_capabilities()

M.setup = function()
  -- Rounded borders for hover/signature/diagnostic floats (replaces vim.lsp.with handlers)
  vim.o.winborder = "rounded"

  vim.diagnostic.config {
    virtual_text = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.HINT] = "",
        [vim.diagnostic.severity.INFO] = "",
      },
    },
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      source = true,
      header = "",
      prefix = "",
    },
  }
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
    vim.diagnostic.open_float()
  end, "Show line diagnostics")
  map("<leader>ci", "<cmd>checkhealth vim.lsp<cr>", "Open LSP info")
  map("<leader>ca", vim.lsp.buf.code_action, "Show code actions")
  map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
  map("<leader>cs", vim.lsp.buf.signature_help, "Show signature help")
  map("<leader>cq", vim.diagnostic.setloclist, "Diagnostics to location list")
  map("<LocalLeader>p", function()
    require("nvim-treesitter.textobjects.lsp_interop").peek_definition_code "@block.outer"
  end, "Peek definition")
  map("[d", function()
    vim.diagnostic.jump { count = -1, float = true }
  end, "Previous diagnostic")
  map("]d", function()
    vim.diagnostic.jump { count = 1, float = true }
  end, "Next diagnostic")
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
