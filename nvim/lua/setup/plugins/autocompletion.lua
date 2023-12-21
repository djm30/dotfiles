local icons = {
  Color = "󰏘",
  Reference = "",
  Folder = "󰉋",
  Text = "󰉿",
  Snippet = "",
  Keyword = "󰌋",
  File = "󰈙",
  Property = "󰜢",
  Module = "󰜢",
  Namespace = "",
  Package = "󰊕",
  Method = "",
  Interface = "",
  Class = "󰌋",
  Constructor = "",
  Field = " ",
  Enum = "",
  Function = "",
  Variable = "",
  Constant = "",
  String = "",
  Number = "#",
  Boolean = "",
  Array = "",
  Object = "",
  Key = "",
  Null = "",
  EnumMember = "",
  Struct = "",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "",
  Component = "",
  Fragment = "",
  Misc = " ",
}

local M = {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-cmdline",
    "rafamadriz/friendly-snippets",
  },
}

M.config = function()
  local cmp = require "cmp"
  local luasnip = require "luasnip"
  require("luasnip.loaders.from_vscode").lazy_load()
  luasnip.config.setup {}

  cmp.setup {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    completion = {
      completeopt = "menu,menuone,noinsert",
    },
    mapping = cmp.mapping.preset.insert {
      ["<C-j>"] = cmp.mapping.select_next_item(),
      ["<C-k>"] = cmp.mapping.select_prev_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete {},
      ["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ["<Tab>"] = cmp.mapping(function(fallback)
        -- Removing tab to cycle autocompletions for now to prioritise tabout
        -- if cmp.visible() then
        --   cmp.select_next_item()
        -- elseif luasnip.expand_or_locally_jumpable() then
        --   luasnip.expand_or_jump()
        --
        --   If in a snippet will jump to next, else should tabout
        if luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        -- if cmp.visible() then
        --   cmp.select_prev_item()
        -- elseif luasnip.locally_jumpable(-1) then
        --   luasnip.jump(-1)
        if luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    },
    sources = {
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "buffer" },
      { name = "path" },
    },
    formatting = {
      fields = { "abbr", "kind", "menu" },
      -- format = function(entry, vim_item)
      --   vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
      --   vim_item.menu = ({
      --     nvim_lsp = "[LSP]",
      --     luasnip = "[Snippet]",
      --     buffer = "[Buffer]",
      --     path = "[Path]",
      --   })[entry.source.name]
      --   return vim_item
      -- end,
      format = function(_, vim_item)
        local icon = icons[vim_item.kind] or ""
        icon = " " .. icon
        vim_item.menu = ("    (" .. vim_item.kind .. ") ")
        vim_item.kind = icon
        return vim_item
      end,
    },

    window = {
      completion = {
        scrollbar = false,
        -- border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      },
      -- documentation = {
      --   border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      -- },
    },
  }

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }),
  })
end

return M
