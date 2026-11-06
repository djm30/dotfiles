-- Oil is the primary file explorer (see filetree.lua for the neo-tree config kept as an alternative)
local function oil_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "oil" then
      return win
    end
  end
end

-- Open oil in a right-hand sidebar (mirrors the old neo-tree position/width)
local function open_sidebar()
  vim.cmd "botright 30vsplit"
  vim.wo.winfixwidth = true
  require("oil").open()
end

local function toggle()
  local win = oil_win()
  if win then
    vim.api.nvim_win_close(win, true)
  else
    open_sidebar()
  end
end

local function focus()
  local win = oil_win()
  if win then
    vim.api.nvim_set_current_win(win)
  else
    open_sidebar()
  end
end

return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = {
      { "<leader>v", toggle, desc = "Toggle Filetree" },
      { "<leader>e", focus, desc = "Focus Filetree" },
    },
    opts = {
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      view_options = { show_hidden = true },
      win_options = { signcolumn = "no", number = false, relativenumber = false },
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
}
