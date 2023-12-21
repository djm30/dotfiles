local M = {
  "natecraddock/workspaces.nvim",
}

local opts_with_desc = require("setup.config.util").opts_with_desc

M.config = function()
  require("workspaces").setup {
    hooks = {
      open = "Neotree show right",
    },
  }
  vim.keymap.set("n", "<leader>wa", ":WorkspacesAdd <CR>", opts_with_desc "Adds current dir as a workspace")
  vim.keymap.set("n", "<leader>wd", ":WorkspacesRemove <CR>", opts_with_desc "Deletes current workspace")
  vim.keymap.set("n", "<leader>wl", ":WorkspacesList <CR>", opts_with_desc "Lists workspaces")
  vim.keymap.set("n", "<leader>wr", ":WorkspacesRename ", opts_with_desc "Renames workspace")
  vim.keymap.set("n", "<leader>wf", ":Telescope workspaces <CR>", opts_with_desc "Find workspace")
end

return M
