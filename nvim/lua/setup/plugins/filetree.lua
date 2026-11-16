-- Kept as an alternative to oil (plugins/oil.lua). Not bound to any keys; use :Neotree toggle.
-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd [[ let g:neo_tree_remove_legacy_commands = 1 ]]

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup {
        window = {
          position = "right",
          width = 30,
        },
        default_component_configs = {
          modified = {
            symbol = "",
          },
          git_status = {
            symbols = {
              untracked = "󱨧",
              unstaged = "󰲶",
              staged = "󰄬",
            },
          },
        },
        filesystem = {
          always_show = {
            ".gitignore",
            "bin",
          },
        },
      }
    end,
  },
}
