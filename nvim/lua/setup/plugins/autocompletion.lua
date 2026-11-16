-- Nerd Font codepoints written as escapes so editors/tools can't strip them
-- Words in the buffer, cached per change, so LSP items the file already uses can rank higher
local buffer_words_cache = {}
local function buffer_words(bufnr)
  local tick = vim.b[bufnr].changedtick
  local cached = buffer_words_cache[bufnr]
  if cached and cached.tick == tick then
    return cached.words
  end
  local words = {}
  if vim.api.nvim_buf_line_count(bufnr) <= 10000 then
    for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
      for word in line:gmatch "[%a_][%w_]*" do
        words[word] = true
      end
    end
  end
  buffer_words_cache[bufnr] = { tick = tick, words = words }
  return words
end

local icons = {
  Color = "\u{f03d8}",
  Reference = "\u{f481}",
  Folder = "\u{f024b}",
  Text = "\u{f0ad}",
  Snippet = "\u{eb66}",
  Keyword = "\u{eb62}",
  File = "\u{f0219}",
  Property = "\u{eb5f}",
  Module = "\u{ea8b}",
  Method = "\u{ea8c}",
  Interface = "\u{f0e8}",
  Class = "\u{eb5b}",
  Constructor = "\u{eb5b}",
  Field = "\u{eb5f}",
  Enum = "\u{ea95}",
  Function = "\u{ea8c}",
  Variable = "\u{ea88}",
  Constant = "\u{e22c}",
  Value = "\u{eb8d}",
  Unit = "\u{ea8f}",
  EnumMember = "\u{eb5e}",
  Struct = "\u{ea91}",
  Event = "\u{f0e7}",
  Operator = "\u{f0195}",
  TypeParameter = "\u{ea92}",
}

return {
  {
    "saghen/blink.cmp",
    version = "1.*", -- release tags ship a prebuilt Rust fuzzy matcher
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      -- Same keys as the old nvim-cmp setup
      keymap = {
        preset = "none",
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<C-d>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-s>"] = { "show_signature", "hide_signature", "fallback" }, -- parameter hints
        ["<CR>"] = { "accept", "fallback" },
        -- Tab only jumps inside snippets; otherwise falls through to tabout
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
      appearance = { kind_icons = icons },
      completion = {
        list = { selection = { preselect = true, auto_insert = false } },
        accept = { auto_brackets = { enabled = true } }, -- replaces the autopairs/cmp hook
        menu = {
          border = "rounded",
          scrollbar = false,
          draw = { columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } } },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded", scrollbar = false } },
      },
      -- Parameter hints pop up after typing `(` or `,` in a call
      signature = { enabled = true, window = { border = "rounded" } },
      sources = {
        default = { "lsp", "snippets", "buffer", "path" },
        providers = {
          lsp = {
            -- Ranking tweaks (typing still matches everything normally):
            --   function parameters (`name=`) first, then names this file already uses
            --   (your variables, functions, imports) above built-ins, language keywords last.
            transform_items = function(ctx, items)
              local kinds = require("blink.cmp.types").CompletionItemKind
              local words = buffer_words(ctx.bufnr)
              for _, item in ipairs(items) do
                local offset = 0
                if item.label:sub(-1) == "=" and item.kind == kinds.Variable then
                  offset = 10
                elseif item.kind == kinds.Keyword then
                  offset = -5
                elseif words[item.label] then
                  offset = 3
                end
                item.score_offset = (item.score_offset or 0) + offset
              end
              return items
            end,
          },
        },
      },
      cmdline = { enabled = false }, -- was disabled in the old cmp config too
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
