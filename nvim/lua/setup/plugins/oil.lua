-- Oil: edit the filesystem like a buffer. `-` opens the current file's folder.
-- The sidebar tree is the snacks explorer (plugins/snacks.lua); neo-tree config kept in filetree.lua.
return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
    },
    opts = {
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      view_options = { show_hidden = true },
      win_options = { signcolumn = "yes:2", number = false, relativenumber = false }, -- signcolumn for git status
      keymaps = {
        -- Free up <C-h/j/k/l> for window navigation
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["<C-s>"] = false, -- aerial toggle
        ["<C-t>"] = false, -- toggleterm
        ["l"] = "actions.select",
        ["h"] = "actions.parent",
        ["q"] = "actions.close",
        ["R"] = "actions.refresh",
      },
    },
  },

  {
    -- Git status icons in oil (like neo-tree had)
    "refractalize/oil-git-status.nvim",
    dependencies = { "stevearc/oil.nvim" },
    ft = "oil",
    opts = {
      symbols = {
        index = { ["A"] = "󰄬", ["M"] = "󰄬", ["D"] = "󰄬", ["R"] = "󰄬", ["C"] = "󰄬", ["?"] = "󱨧", ["!"] = "" },
        working_tree = { ["A"] = "󰲶", ["M"] = "󰲶", ["D"] = "󰲶", ["R"] = "󰲶", ["C"] = "󰲶", ["?"] = "󱨧", ["!"] = "" },
      },
    },
  },
}
