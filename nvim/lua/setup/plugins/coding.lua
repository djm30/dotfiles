return {

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      require("nvim-autopairs").setup {}
      -- If you want to automatically add `(` after selecting a function or method
      local cmp_autopairs = require "nvim-autopairs.completion.cmp"
      local cmp = require "cmp"
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  {
    "stevearc/conform.nvim",
    config = function()
      local web = { "prettierd", "prettier", stop_after_first = true }
      require("conform").setup {
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "isort", "black" }, -- run sequentially
          javascript = web,
          typescript = web,
          typescriptreact = web,
          javascriptreact = web,
          svelte = web,
          json = web,
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      }
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require "lint"
      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        svelte = { "eslint_d" },
      }

      vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {}
    end,
  },

  {
    "abecodes/tabout.nvim",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("tabout").setup {
        tabkey = "<Tab>", -- key to trigger tabout, set to an empty string to disable
        backwards_tabkey = "<S-Tab>", -- key to trigger backwards tabout, set to an empty string to disable
        act_as_tab = true, -- shift content if tab out is not possible
        act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
        default_tab = "<C-t>", -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
        default_shift_tab = "<C-d>", -- reverse shift default action,
        enable_backwards = true, -- well ...
        completion = true, -- if the tabkey is used in a completion pum
        tabouts = {
          { open = "'", close = "'" },
          { open = '"', close = '"' },
          { open = "`", close = "`" },
          { open = "(", close = ")" },
          { open = "[", close = "]" },
          { open = "{", close = "}" },
        },
        ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
        exclude = {}, -- tabout will ignore these filetypes
      }
    end,
  },

  "tpope/vim-sleuth", -- Automatically detects which indents should be used in the current buffer

  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
  },
  {
    "ThePrimeagen/refactoring.nvim", -- Refactor code like Martin Fowler
    lazy = true,
    init = function()
      require("legendary").keymaps {
        {
          itemgroup = "Refactoring",
          icon = "",
          description = "Refactor code...",
          keymaps = {
            {
              "<Leader>rf",
              function()
                return require("refactoring").select_refactor()
              end,
              description = "Select refactor",
              mode = { "n", "x" },
            },
            {
              "<LocalLeader>rd",
              function()
                return require("refactoring.debug").print_loc { output_location = "above" }
              end,
              description = "Insert print statement for debugging",
              opts = { expr = true },
            },
            {
              "<LocalLeader>rv",
              {
                n = function()
                  return require("refactoring.debug").print_var { output_location = "below" } .. "iw"
                end,
                x = function()
                  return require("refactoring.debug").print_var { output_location = "below" }
                end,
              },
              description = "Insert print var statement for debugging",
              opts = { expr = true },
            },
            {
              "<LocalLeader>rc",
              function()
                -- Operator now needs a range: jump to top, then apply to the whole buffer (G)
                return "gg" .. require("refactoring.debug").cleanup { restore_view = true } .. "G"
              end,
              description = "Cleanup debug statements",
              opts = { expr = true },
            },
          },
        },
      }
    end,
    config = true,
  },
}
