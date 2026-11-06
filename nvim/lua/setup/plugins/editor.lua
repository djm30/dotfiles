return {
  {
    "akinsho/toggleterm.nvim",
    event = "VeryLazy",
    config = function()
      require("toggleterm").setup {
        size = 20,
        open_mapping = [[<C-t>]],
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 1, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
        start_in_insert = true,
        insert_mappings = false, -- whether or not the open mapping applies in insert mode
        persist_size = false,
        direction = "float",
        close_on_exit = true, -- close the terminal window when the process exits
        shell = nil, -- change the default shell
        float_opts = {
          border = "rounded",
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
        winbar = {
          enabled = true,
          name_formatter = function(term) --  term: Terminalauto
            return term.count
          end,
        },
      }

    end,
  },

  {
    "stevearc/aerial.nvim", -- Toggled list of classes, methods etc in current file
    opts = {
      backends = { "lsp", "markdown", "asciidoc", "man" },
      attach_mode = "global",
      close_on_select = true,
      layout = {
        min_width = 30,
        default_direction = "left",
      },
      -- Use nvim-navic icons
      icons = {
        File = "󰈙 ",
        Module = " ",
        Namespace = "󰌗 ",
        Package = " ",
        Class = "󰌗 ",
        Method = "󰆧 ",
        Property = " ",
        Field = " ",
        Constructor = " ",
        Enum = "󰕘",
        Interface = "󰕘",
        Function = "󰊕 ",
        Variable = "󰆧 ",
        Constant = "󰏿 ",
        String = "󰀬 ",
        Number = "󰎠 ",
        Boolean = "◩ ",
        Array = "󰅪 ",
        Object = "󰅩 ",
        Key = "󰌋 ",
        Null = "󰟢 ",
        EnumMember = " ",
        Struct = "󰌗 ",
        Event = " ",
        Operator = "󰆕 ",
        TypeParameter = "󰊄 ",
      },
    },
    init = function()
      require("legendary").keymaps {
        {
          "<C-s>",
          function()
            require("aerial").toggle()
          end,
          mode = { "n", "x", "o" },
          description = "Aerial toggle",
        },
      }
    end,
  },

  {
    "folke/todo-comments.nvim", -- Highlight and search for todo comments within the codebase
    event = "BufEnter",
    init = function()
      require("legendary").keymaps {
        { "<Leader>t", "<cmd>TodoTelescope<CR>", description = "Todo comments" },
      }
    end,
    opts = {
      signs = false,
      highlight = {
        keyword = "bg",
      },
      keywords = {
        FIX = { icon = " " }, -- Custom fix icon
      },
    },
  },

  {
    url = "https://codeberg.org/andyg/leap.nvim", -- moved off GitHub
    config = function()
      -- Same keys as the old create_default_mappings()
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)")
      vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")
      vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)")
    end,
  },
}
