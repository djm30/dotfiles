return {

  {
    "windwp/nvim-autopairs",
    -- Optional dependency
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

    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },

  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
    config = function()
      require("Comment").setup()
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
      require("conform").setup {
        formatters_by_ft = {
          lua = { "stylua" },
          -- Conform will run multiple formatters sequentially
          python = { "isort", "black" },
          -- Use a sub-list to run only the first available formatter
          javascript = { { "prettierd", "prettier", "eslint_d" } },
          typescript = { { "prettierd", "prettier", "eslint_d" } },
          typescriptreact = { { "prettierd", "prettier", "eslint_d" } },
          javascriptreact = { { "prettierd", "prettier", "eslint_d" } },
          json = { "prettierd", "prettier" },
        },

        -- TODO Maybe think about disabling this
        format_on_save = {
          -- These options will be passed to conform.format()
          timeout_ms = 500,
          lsp_fallback = true,
        },
      }
    end,
  },

  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require "lint"

      lint.linters_by_ft = {
        javascript = {
          "eslint_d",
        },
        typescript = {
          "eslint_d",
        },
        javascriptreact = {
          "eslint_d",
        },
        typescriptreact = {
          "eslint_d",
        },
        svelte = {
          "eslint_d",
        },
      }

      vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost" }, {
        callback = function()
          local lint_status, lint = pcall(require, "lint")
          if lint_status then
            lint.try_lint()
          end
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
    wants = { "nvim-treesitter" }, -- or require if not used so far
    after = { "nvim-cmp" }, -- if a completion plugin is using tabs load it before
  },

  "tpope/vim-sleuth", -- Automatically detects which indents should be used in the current buffer
  {
    "echasnovski/mini.diff",
    config = function()
      local diff = require "mini.diff"
      diff.setup {
        -- Disabled by default
        source = diff.gen_source.none(),
      }
    end,
  },

  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.keymap.set("i", "<C-CR>", 'copilot#Accept("<CR>")', { expr = true, silent = true, replace_keycodes = false })
    end,
  },

  {
    "olimorris/codecompanion.nvim",
    config = function()
      require("codecompanion").setup {
        adapters = {
          -- anthropic = function()
          --   return require("codecompanion.adapters").extend("anthropic", {
          --     env = {
          --       api_key = "cmd:op read op://personal/Anthropic_API/credential --no-newline",
          --     },
          --   })
          -- end,
          -- gemini = function()
          --   return require("codecompanion.adapters").extend("gemini", {
          --     env = {
          --       api_key = "cmd:op read op://personal/Gemini_API/credential --no-newline",
          --     },
          --   })
          -- end,
          -- openai = function()
          --   return require("codecompanion.adapters").extend("openai", {
          --     env = {
          --       api_key = "cmd:op read op://personal/OpenAI_API/credential --no-newline",
          --     },
          --   })
          -- end,
          -- xai = function()
          --   return require("codecompanion.adapters").extend("xai", {
          --     env = {
          --       api_key = "cmd:op read op://personal/xAI_API/credential --no-newline",
          --     },
          --   })
          -- end,
        },
        strategies = {
          chat = {
            roles = { llm = "  CodeCompanion", user = "Dylan" },
            adapter = "copilot",
          },
          inline = {
            adapter = "copilot",
          },
        },
        display = {
          chat = {
            window = {
              layout = "vertical", -- float|vertical|horizontal|buffer
            },
          },
          diff = {
            close_chat_at = 500,
            provider = "mini_diff",
          },
        },
        opts = {
          log_level = "DEBUG",
        },
      }
    end,
    init = function()
      vim.cmd [[cab cc CodeCompanion]]
      require("legendary").keymaps {
        {
          itemgroup = "CodeCompanion",
          icon = "",
          description = "Use the power of AI...",
          keymaps = {
            {
              "<C-a>",
              "<cmd>CodeCompanionActions<CR>",
              description = "Open the action palette",
              mode = { "n", "v" },
            },
            {
              "<LocalLeader>a",
              "<cmd>CodeCompanionChat Toggle<CR>",
              description = "Toggle a chat buffer",
              mode = { "n", "v" },
            },
            {
              "ga",
              "<cmd>CodeCompanionChat Add<CR>",
              description = "Add selected text to a chat buffer",
              mode = { "n", "v" },
            },
          },
        },
      }
    end,
  },
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
                require("telescope").extensions.refactoring.refactors()
              end,
              description = "Open Refactoring.nvim",
              mode = { "n", "v", "x" },
            },
            {
              "<LocalLeader>rd",
              function()
                require("refactoring").debug.printf { below = false }
              end,
              description = "Insert Printf statement for debugging",
            },
            {
              "<LocalLeader>rv",
              {
                n = function()
                  require("refactoring").debug.print_var { normal = true }
                end,
                x = function()
                  require("refactoring").debug.print_var {}
                end,
              },
              description = "Insert Print_Var statement for debugging",
              mode = { "n", "v" },
            },
            {
              "<LocalLeader>rc",
              function()
                require("refactoring").debug.cleanup()
              end,
              description = "Cleanup debug statements",
            },
          },
        },
      }
    end,
    config = true,
  },
}
