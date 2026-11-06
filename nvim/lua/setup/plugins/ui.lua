local fn = require "setup.config.functions"

return {
  "nvim-tree/nvim-web-devicons",
  {
    "folke/edgy.nvim", -- Create predefined window layouts
    event = "VeryLazy",
    init = function()
      vim.opt.laststatus = 3
      vim.opt.splitkeep = "screen"
    end,
    opts = {
      animate = { enabled = false },
      options = {
        top = { size = 10 },
      },
      bottom = {
        {
          ft = "terminal",
          title = "Terminal",
          size = { height = fn.on_big_screen() and 20 or 0.2 },
          filter = function(buf)
            return not vim.b[buf].lazyterm_cmd
          end,
        },
        { ft = "qf", title = "QuickFix" },
        {
          ft = "help",
          size = { height = 20 },
          -- only show help buffers
          filter = function(buf)
            return vim.bo[buf].buftype == "help"
          end,
        },
        { title = "Neotest Output", ft = "neotest-output-panel", size = { height = 15 } },
      },
      right = {
        { ft = "aerial", title = "Symbols", size = { width = 0.3 } },
        { ft = "neotest-summary", title = "Neotest Summary", size = { width = 0.3 } },
      },
    },
  },

  {
    "lukas-reineke/virt-column.nvim", -- Use characters in the color column
    opts = {
      char = "│",
      highlight = "VirtColumn",
    },
  },

  {
    "tzachar/local-highlight.nvim", -- Highlight word under cursor throughout the visible buffer
    opts = {
      file_types = { "lua", "javascript", "python", "ruby" },
      animate = { enabled = false },
    },
  },

  {
    "lewis6991/gitsigns.nvim", -- Git signs in the statuscolumn
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "│" },
        topdelete = { text = "│" },
        changedelete = { text = "│" },
        untracked = { text = "│" },
      },
      signs_staged_enable = false,
      numhl = false,
      linehl = false,
    },
    config = function()
      require("gitsigns").setup {

        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          map("n", "<leader>gb", function()
            gs.blame_line { full = true }
          end)
          map("n", "<leader>gtb", gs.toggle_current_line_blame)
          map("n", "<leader>gd", gs.diffthis)
          map("n", "<leader>gtd", gs.toggle_deleted)

          -- map("n", "<leader>hD", function()
          --   gs.diffthis "~"
          -- end)
        end,
      }
    end,
  },

  {
    "NvChad/nvim-colorizer.lua", -- Highlight hex and rgb colors within Neovim
    event = { "BufReadPost", "BufNewFile" },
    cmd = "ColorizerToggle",
    init = function()
      require("legendary").commands {
        {
          ":ColorizerToggle",
          description = "Colorizer toggle",
        },
      }
    end,
    opts = {
      filetypes = {
        "css",
        eruby = { mode = "foreground" },
        html = { mode = "foreground" },
        "lua",
        "javascript",
        "vue",
      },
    },
  },
}
