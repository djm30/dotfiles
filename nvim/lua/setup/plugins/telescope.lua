-- local M = {
--   "nvim-telescope/telescope.nvim",
--   branch = "0.1.x",
--   dependencies = {
--     "nvim-lua/plenary.nvim",
--     {
--       "nvim-telescope/telescope-fzf-native.nvim",
--       build = "make",
--       cond = function()
--         return vim.fn.executable "make" == 1
--       end,
--     },
--     "nvim-telescope/telescope-ui-select.nvim",
--   },
-- }
--
-- M.config = function()
--   local actions = require "telescope.actions"
--   require("telescope").setup {
--     defaults = {
--
--       file_ignore_patterns = {
--         "node_modules",
--       },
--       -- prompt_prefix = " ",
--       selection_caret = " ",
--       path_display = { "smart" },
--
--       layout_strategy = "horizontal",
--       layout_config = {
--         horizontal = {
--           prompt_position = "top",
--         },
--       },
--       sorting_strategy = "ascending",
--
--       winblend = 0,
--
--       mappings = {
--         i = {
--           ["<C-n>"] = actions.cycle_history_next,
--           ["<C-p>"] = actions.cycle_history_prev,
--
--           ["<C-j>"] = actions.move_selection_next,
--           ["<C-k>"] = actions.move_selection_previous,
--
--           ["<C-c>"] = actions.close,
--
--           ["<Down>"] = actions.move_selection_next,
--           ["<Up>"] = actions.move_selection_previous,
--
--           ["<CR>"] = actions.select_default,
--           ["<C-x>"] = actions.select_horizontal,
--           ["<C-v>"] = actions.select_vertical,
--           ["<C-t>"] = actions.select_tab,
--
--           ["<C-u>"] = actions.preview_scrolling_up,
--           ["<C-d>"] = actions.preview_scrolling_down,
--
--           ["<PageUp>"] = actions.results_scrolling_up,
--           ["<PageDown>"] = actions.results_scrolling_down,
--
--           ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
--           ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
--           ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
--           ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
--           ["<C-l>"] = actions.complete_tag,
--           ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
--
--           ["<S-d>"] = actions.delete_buffer,
--         },
--
--         n = {
--           ["<esc>"] = actions.close,
--           ["<CR>"] = actions.select_default,
--           ["<C-x>"] = actions.select_horizontal,
--           ["<C-v>"] = actions.select_vertical,
--           ["<C-t>"] = actions.select_tab,
--
--           ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
--           ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
--           ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
--           ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
--
--           ["j"] = actions.move_selection_next,
--           ["k"] = actions.move_selection_previous,
--           ["H"] = actions.move_to_top,
--           ["M"] = actions.move_to_middle,
--           ["L"] = actions.move_to_bottom,
--
--           ["<Down>"] = actions.move_selection_next,
--           ["<Up>"] = actions.move_selection_previous,
--           ["gg"] = actions.move_to_top,
--           ["G"] = actions.move_to_bottom,
--
--           ["<C-u>"] = actions.preview_scrolling_up,
--           ["<C-d>"] = actions.preview_scrolling_down,
--
--           ["<PageUp>"] = actions.results_scrolling_up,
--           ["<PageDown>"] = actions.results_scrolling_down,
--
--           ["<S-d>"] = actions.delete_buffer,
--
--           ["?"] = actions.which_key,
--         },
--       },
--     },
--     pickers = {
--       planets = {
--         show_pluto = true,
--       },
--     },
--     extensions = {
--       "fzf",
--       "projects",
--       ["ui-select"] = {
--         require("telescope.themes").get_dropdown {},
--
--         -- pseudo code / specification for writing custom displays, like the one
--         -- for "codeactions"
--         -- specific_opts = {
--         --   [kind] = {
--         --     make_indexed = function(items) -> indexed_items, width,
--         --     make_displayer = function(widths) -> displayer
--         --     make_display = function(displayer) -> function(e)
--         --     make_ordinal = function(e) -> string
--         --   },
--         --   -- for example to disable the custom builtin "codeactions" display
--         --      do the following
--         --   codeactions = false,
--         -- }
--       },
--     },
--   }
--
--   pcall(require("telescope").load_extension, "fzf")
--   pcall(require("telescope").load_extension, "workspaces")
--   pcall(require("telescope").load_extension, "ui-select")
--
--   -- See `:help telescope.builtin`
--   vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "Find recently opened files" })
--   vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers, { desc = "Find existing buffers" })
--
--   vim.keymap.set("n", "<leader>/", function()
--     -- You can pass additional configuration to telescope to change theme, layout, etc.
--     require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
--       winblend = 10,
--       previewer = false,
--     })
--   end, { desc = "Fuzzily search in current buffer" })
--
--   local function telescope_live_grep_open_files()
--     require("telescope.builtin").live_grep {
--       grep_open_files = true,
--       prompt_title = "Live Grep in Open Files",
--     }
--   end
--
--   vim.keymap.set("n", "<leader>fo", telescope_live_grep_open_files, { desc = "Grep open files" })
--   vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
--   vim.keymap.set("n", "<leader>fp", require("telescope").extensions.workspaces.workspaces, { desc = "Find Projects" })
--   vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Find by Grep" })
--   vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Find help" })
--   vim.keymap.set("n", "<leader>fw", require("telescope.builtin").grep_string, { desc = "Find current word" })
--   vim.keymap.set("n", "<leader>fd", require("telescope.builtin").diagnostics, { desc = "Find diagnostics" })
--   vim.keymap.set("n", "<leader>fr", require("telescope.builtin").resume, { desc = "Resume casched search" })
--   vim.keymap.set("n", "<leader>fs", require("telescope.builtin").builtin, { desc = "Find telescopes" })
--
--   -- vim.keymap.set("n", "<leader>fp", require("telescope.builtin").git_files, { desc = "[P]roject (git) [F]iles" })
--   -- vim.keymap.set("n", "<leader>fpg", ":LiveGrepGitRoot<cr>", { desc = "[F]ind by [P]roject files (git) with [G]rep" })
-- end
--
-- return M
--
return {
  {
    "nvim-telescope/telescope.nvim", -- Awesome fuzzy finder for everything
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "debugloop/telescope-undo.nvim", -- Visualise undotree
        config = function()
          require("telescope").load_extension "undo"
        end,
        init = function()
          require("legendary").keymaps {
            { "<LocalLeader>u", "<cmd>Telescope undo<CR>", description = "Undo tree using Telescope" },
          }
        end,
      },
      {
        "nvim-telescope/telescope-frecency.nvim", -- Get frequently opened files
        config = function()
          require("telescope").load_extension "frecency"
        end,
      },
    },
    init = function()
      local t = require "legendary.toolbox"
      require("legendary").keymaps {
        {
          itemgroup = "Telescope",
          description = "Gaze deeply into unknown regions using the power of the moon",
          icon = "",
          keymaps = {
            {
              "<C-f>",
              t.lazy_required_fn("telescope.builtin", "find_files", { hidden = true }),
              description = "Find files",
            },
            {
              "<C-g>",
              t.lazy_required_fn(
                "telescope.builtin",
                "live_grep",
                { prompt_title = "Open Files", path_display = { "shorten" }, grep_open_files = true }
              ),
              description = "Find in open files",
            },
            {
              "<Leader>g",
              t.lazy_required_fn(
                "telescope.builtin",
                "live_grep",
                { prompt_title = "Search CWD", path_display = { "smart" } }
              ),
              description = "Search CWD",
            },
            {
              "<C-b>",
              t.lazy_required_fn(
                "telescope.builtin",
                "buffers",
                { prompt_title = "Buffer List", path_display = { "smart" } }
              ),
              description = "List buffers",
            },
            {
              "<Leader><Leader>",
              "<cmd>lua require('telescope').extensions.frecency.frecency({ prompt_title = 'Recent Files', workspace = 'CWD', path_display = { 'smart' } })<CR>",
              description = "Find recent files",
            },
          },
        },
      }
    end,
    config = function()
      local actions = require "telescope.actions"
      local action_state = require "telescope.actions.state"
      local custom_actions = {}

      function custom_actions.multi_select(prompt_bufnr)
        local function get_table_size(t)
          local count = 0
          for _ in pairs(t) do
            count = count + 1
          end
          return count
        end

        local picker = action_state.get_current_picker(prompt_bufnr)
        local num_selections = get_table_size(picker:get_multi_selection())

        if num_selections > 1 then
          actions.send_selected_to_qflist(prompt_bufnr)
          actions.open_qflist()
        else
          actions.file_edit(prompt_bufnr)
        end
      end

      local telescope = require "telescope"
      telescope.setup {
        defaults = {
          -- Appearance
          entry_prefix = "  ",
          prompt_prefix = "   ",
          selection_caret = "  ",
          color_devicons = true,
          path_display = { "smart" },
          dynamic_preview_title = true,

          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              height = om.on_big_screen() and 0.6 or 0.95,
              preview_width = 0.55,
              prompt_position = "top",
              width = 0.9,
            },
            center = {
              anchor = "N",
              width = 0.9,
              preview_cutoff = 10,
            },
            vertical = {
              height = om.on_big_screen() and 0.4 or 0.9,
              preview_height = 0.3,
              width = 0.9,
              preview_cutoff = 10,
              prompt_position = "top",
            },
          },

          -- Searching
          set_env = { COLORTERM = "truecolor" },
          file_ignore_patterns = {
            ".git/",
            "%.jpg",
            "%.jpeg",
            "%.png",
            "%.svg",
            "%.otf",
            "%.ttf",
            "%.lock",
            "__pycache__",
            "%.sqlite3",
            "%.ipynb",
            "vendor",
            "node_modules",
            "dotbot",
          },
          file_sorter = require("telescope.sorters").get_fuzzy_file,

          -- Mappings
          mappings = {
            i = {
              ["<esc>"] = require("telescope.actions").close,
              ["<C-e>"] = custom_actions.multi_select,
              ["<C-c>"] = require("telescope.actions").delete_buffer,
              ["<C-j>"] = require("telescope.actions").move_selection_next,
              ["<C-d>"] = require("telescope.actions").preview_scrolling_down,
              ["<C-f>"] = require("telescope.actions").preview_scrolling_up,
              ["<C-k>"] = require("telescope.actions").move_selection_previous,
              ["<C-q>"] = require("telescope.actions").send_selected_to_qflist,
            },
            n = {
              ["q"] = require("telescope.actions").close,
              ["<C-n>"] = require("telescope.actions").move_selection_next,
              ["<C-p>"] = require("telescope.actions").move_selection_previous,
            },
          },
        },

        extensions = {
          frecency = {
            show_scores = false,
            show_unindexed = false,
            ignore_patterns = {
              "*.git/*",
              "*/tmp/*",
              "*/node_modules/*",
              "*/vendor/*",
            },
            -- workspaces = {
            --   ["nvim"] = os.getenv("HOME_DIR") .. ".config/nvim",
            --   ["dots"] = os.getenv("HOME_DIR") .. ".dotfiles",
            --   ["project"] = os.getenv("PROJECT_DIR"),
            -- },
          },
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          undo = {
            mappings = {
              i = {
                ["<CR>"] = require("telescope-undo.actions").restore,
                ["<C-a>"] = require("telescope-undo.actions").yank_additions,
                ["<C-d>"] = require("telescope-undo.actions").yank_deletions,
              },
            },
          },
        },
      }

      -- Extensions
      telescope.load_extension "aerial"
      telescope.load_extension "persisted"
      telescope.load_extension "refactoring"
    end,
  },
}
