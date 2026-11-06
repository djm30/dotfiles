local icons = {
  Color = "󰏘",
  Reference = "",
  Folder = "󰉋",
  Text = "",
  Snippet = "",
  Keyword = "",
  File = "󰈙",
  Property = "",
  Module = "",
  Method = "",
  Interface = "",
  Class = "",
  Constructor = "",
  Field = "",
  Enum = "",
  Function = "",
  Variable = "",
  Constant = "",
  Value = "",
  Unit = "",
  EnumMember = "",
  Struct = "",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "",
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
      sources = { default = { "lsp", "snippets", "buffer", "path" } },
      cmdline = { enabled = false }, -- was disabled in the old cmp config too
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
