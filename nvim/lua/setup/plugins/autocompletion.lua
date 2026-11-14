-- Nerd Font codepoints written as escapes so editors/tools can't strip them
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
      sources = { default = { "lsp", "snippets", "buffer", "path" } },
      cmdline = { enabled = false }, -- was disabled in the old cmp config too
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
