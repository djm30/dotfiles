local M = {}

M.capabilities = require("blink.cmp").get_lsp_capabilities()

M.setup = function()
  -- Rounded borders for hover/signature/diagnostic floats (replaces vim.lsp.with handlers)
  vim.o.winborder = "rounded"

  vim.diagnostic.config {
    virtual_text = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "\u{f057}",
        [vim.diagnostic.severity.WARN] = "\u{f071}",
        [vim.diagnostic.severity.HINT] = "\u{f06a}",
        [vim.diagnostic.severity.INFO] = "\u{f05a}",
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
    require("setup.config.util").document(lhs, "LSP: " .. desc)
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
    -- Show the definition in a floating window without jumping to it
    local client = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/definition" })[1]
    if not client then
      return
    end
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    client:request("textDocument/definition", params, function(_, result)
      if not result or vim.tbl_isempty(result) then
        return vim.notify("No definition found", vim.log.levels.INFO)
      end
      local location = vim.islist(result) and result[1] or result
      vim.lsp.util.preview_location(location, { border = "rounded" })
    end, bufnr)
  end, "Peek definition")
  map("[d", function()
    vim.diagnostic.jump { count = -1, float = true }
  end, "Previous diagnostic")
  map("]d", function()
    vim.diagnostic.jump { count = 1, float = true }
  end, "Next diagnostic")
end

-- Servers whose formatting is handled by conform instead
local no_format = { ts_ls = true, tsserver = true, ["typescript-tools"] = true, lua_ls = true, ruff = true }

M.on_attach = function(client, bufnr)
  if no_format[client.name] then
    client.server_capabilities.documentFormattingProvider = false
  end
  if client.name == "ruff" then
    client.server_capabilities.hoverProvider = false -- ty's hover is the useful one
  end

  lsp_keymaps(bufnr)
end

-- Attach keymaps via LspAttach rather than each server's on_attach: several nvim-lspconfig
-- configs (pyright, clangd, rust_analyzer, svelte...) define their own on_attach, which
-- replaces a shared one instead of adding to it.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("setup_lsp_attach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      M.on_attach(client, args.buf)
    end
  end,
})

return M
