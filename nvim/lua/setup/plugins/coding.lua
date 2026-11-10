return {

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {}, -- `(` after accepting a function is handled by blink's auto_brackets
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo", "FormatToggle" },
    keys = {
      {
        "<leader>cf",
        function()
          vim.cmd "FormatToggle"
        end,
        desc = "Toggle format on save (global)",
      },
    },
    config = function()
      -- Prettier only runs when the project has a Prettier config; no LSP fallback for these filetypes,
      -- so repos without Prettier are left untouched.
      local web = { "prettierd", "prettier", stop_after_first = true, lsp_format = "never" }
      -- Same idea for Swift: `swift format` only runs when the project has a .swift-format config
      -- (sourcekit-lsp would otherwise format with swift-format's defaults).
      local swift = { "swift", lsp_format = "never" }

      -- Ruff only formats projects that configure it: ruff.toml / .ruff.toml, or [tool.ruff] in pyproject.toml
      local function uses_ruff(_, ctx)
        if vim.fs.find({ "ruff.toml", ".ruff.toml" }, { path = ctx.dirname, upward = true })[1] then
          return true
        end
        local pyproject = vim.fs.find("pyproject.toml", { path = ctx.dirname, upward = true })[1]
        local f = pyproject and io.open(pyproject)
        if not f then
          return false
        end
        local content = f:read "*a"
        f:close()
        return content:find("%[tool%.ruff") ~= nil
      end

      require("conform").setup {
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_organize_imports", "ruff_format", lsp_format = "never" },
          javascript = web,
          typescript = web,
          typescriptreact = web,
          javascriptreact = web,
          svelte = web,
          json = web,
          jsonc = web,
          css = web,
          scss = web,
          html = web,
          yaml = web,
          markdown = web,
          swift = swift,
        },
        formatters = {
          prettierd = { require_cwd = true },
          prettier = { require_cwd = true },
          ruff_format = { condition = uses_ruff },
          ruff_organize_imports = { condition = uses_ruff },
          swift = { require_cwd = true, cwd = require("conform.util").root_file { ".swift-format" } },
        },
        format_on_save = function(bufnr)
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          -- No lsp_format here: options returned by format_on_save override the per-filetype
          -- lsp_format = "never" above. The LSP fallback lives in default_format_opts instead.
          return { timeout_ms = 500 }
        end,
        default_format_opts = { lsp_format = "fallback" },
      }

      -- :FormatToggle toggles for everything, :FormatToggle! for the current buffer only
      vim.api.nvim_create_user_command("FormatToggle", function(args)
        local scope, store = "globally", vim.g
        if args.bang then
          scope, store = "for this buffer", vim.b
        end
        store.disable_autoformat = not store.disable_autoformat
        vim.notify(("Format on save %s %s"):format(store.disable_autoformat and "disabled" or "enabled", scope))
      end, { bang = true, desc = "Toggle format on save (! = buffer only)" })
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
