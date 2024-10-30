return {
  {
    -- Manual install script
    -- cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app
    -- ./install.sh
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    event = "VeryLazy",
    commit = "c80844fd52ba76f48fabf83e2b9f9b93273f418d",
    config = function()
      require("toggleterm").setup {
        size = 20,
        open_mapping = [[<C-t>]],
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 1, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
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

      -- Lazygit terminal setup
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new { cmd = "lazygit", hidden = true }

      function _lazygit_toggle()
        lazygit:toggle()
        if lazygit:is_open() then
          vim.cmd "startinsert"
        end
      end

      -- Set key mapping for the lazygit terminal
      local map = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = true, desc = "Open Lazygit" }
      map("n", "<leader>gg", "<cmd>lua _lazygit_toggle()<CR>", opts)
    end,
  },

  {
    "stevearc/aerial.nvim", -- Toggled list of classes, methods etc in current file
    opts = {
      attach_mode = "global",
      close_on_select = true,
      layout = {
        min_width = 30,
        default_direction = "prefer_right",
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
          "<C-t>",
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
}
