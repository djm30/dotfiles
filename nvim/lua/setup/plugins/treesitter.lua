local M = {
  -- Highlight, edit, and navigate code
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    "windwp/nvim-ts-autotag",
    "nvim-treesitter/playground",
  },
  build = ":TSUpdate",
}

M.config = function()
  vim.defer_fn(function()
    require("nvim-treesitter.configs").setup {
      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = {
        "c",
        "go",
        "lua",
        "python",
        "rust",
        "tsx",
        "javascript",
        "tsx",
        "html",
        "css",
        "typescript",
        "vimdoc",
        "vim",
        "bash",
        "svelte",
      },

      -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
      auto_install = true,

      autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_slash = true,
        filetypes = {
          "tsx",
          "jsx",
          "html",
          "xml",
          "svelte",
          "typescriptreact",
          "typescript",
          "javascript",
          "javascriptreact",
        },
      },

      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          scope_incremental = "<c-s>",
          node_decremental = "<M-space>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
        swap = {
          -- I dont really know what this is or if i will ever use it
          enable = false,
          swap_next = {
            ["<leader>a"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>A"] = "@parameter.inner",
          },
        },
      },
    }

    require("setup.config.treesitter.styled-components").directives()
    require("setup.config.treesitter.styled-components").queries()
  end, 0)

  require("nvim-treesitter.configs").setup {
    playground = {
      enable = true,
      disable = {},
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = false, -- Whether the query persists across vim sessions
      keybindings = {
        toggle_query_editor = "o",
        toggle_hl_groups = "i",
        toggle_injected_languages = "t",
        toggle_anonymous_nodes = "a",
        toggle_language_display = "I",
        focus_language = "f",
        unfocus_language = "F",
        update = "R",
        goto_node = "<cr>",
        show_help = "?",
      },
    },
  }
end

return M

-- return {
--   {
--     "nvim-treesitter/nvim-treesitter", -- Smarter code understanding like syntax Highlight and navigation
--     build = ":TSUpdate",
--     dependencies = {
--       "nvim-treesitter/nvim-treesitter-textobjects", -- Syntax aware text-objects, select, move, swap, and peek support.
--       {
--         "JoosepAlviste/nvim-ts-context-commentstring", -- Smart commenting in multi language files - Enabled in Treesitter file
--       },
--       {
--         "windwp/nvim-ts-autotag", -- Autoclose and autorename HTML and Vue tags
--         config = true,
--       },
--       {
--         "PriceHiller/nvim-treesitter-endwise", -- Automatically add end keywords for Ruby, Lua, Python, and more
--         branch = "fix/iter-matches",
--       },
--     },
--     config = function()
--       require("setup.config.styled-components").directives()
--       require("setup.config.styled-components").queries()
--       require("nvim-treesitter.configs").setup({
--         sync_install = false,
--         auto_install = false,
--         ensure_installed = "all",
--         ignore_install = { "phpdoc" }, -- list of parser which cause issues or crashes
--         highlight = { enable = true },
--         incremental_selection = {
--           enable = true,
--           keymaps = {
--             init_selection = "<M-w>",
--             scope_incremental = "<CR>",
--             node_incremental = "<Tab>", -- increment to the upper named parent
--             node_decremental = "<S-Tab>", -- decrement to the previous node
--           },
--         },
--         indent = { enable = true },
--
--         -- nvim-treesitter-endwise plugin
--         endwise = { enable = true },
--
--         textobjects = {
--           select = {
--             enable = true,
--             lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
--
--             keymaps = {
--               -- Use v[keymap], c[keymap], d[keymap] to perform any operation
--               ["af"] = "@function.outer",
--               ["if"] = "@function.inner",
--               ["ac"] = "@class.outer",
--             },
--           },
--         },
--       })
--     end,
--   },
-- }
--
