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
      current_line_blame_opts = { delay = 300 },
      on_attach = function(bufnr)
        local gs = require "gitsigns"
        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
          require("setup.config.util").document(lhs, "Git: " .. desc)
        end

        map("<leader>gb", function()
          gs.blame_line { full = true }
        end, "Blame line (popup)")
        map("<leader>gB", gs.blame, "Blame whole file")
        map("<leader>gtb", gs.toggle_current_line_blame, "Toggle inline blame")
        map("<leader>gtd", gs.preview_hunk_inline, "Preview hunk inline")
      end,
    },
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
