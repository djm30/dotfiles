-- snacks.nvim replaces: dashboard-nvim, indent-blankline, bufdelete, dressing, the toggleterm lazygit terminal,
-- and provides the sidebar file tree (explorer)

local function explorer_picker()
  return Snacks.picker.get({ source = "explorer" })[1]
end
local header = [[
  ██╗    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗        ██╗    ██╗  
 ██╔╝    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║       ██╔╝    ╚██╗ 
██╔╝     ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║      ██╔╝      ╚██╗
╚██╗     ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║     ██╔╝       ██╔╝
 ╚██╗    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    ██╔╝       ██╔╝ 
  ╚═╝    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═╝        ╚═╝  ]]

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      {
        "<leader>v",
        function()
          local picker = explorer_picker()
          if picker then
            picker:close()
          else
            Snacks.explorer()
          end
        end,
        desc = "Toggle file tree",
      },
      {
        "<leader>e",
        function()
          local picker = explorer_picker()
          if picker then
            picker:focus()
          else
            Snacks.explorer()
          end
        end,
        desc = "Focus file tree",
      },
      {
        "<C-c>",
        function()
          Snacks.bufdelete()
        end,
        desc = "Close buffer (keep window)",
      },
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "Open Lazygit",
      },
    },
    opts = {
      dashboard = {
        preset = {
          header = header,
          keys = {
            { icon = "󰊳 ", key = "u", desc = "Update", action = ":Lazy update" },
            { icon = " ", key = "f", desc = "Files", action = ":Telescope find_files" },
            { icon = " ", key = "e", desc = "Filetree", action = function() Snacks.explorer() end },
            { icon = "󰗼 ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header", padding = 2 },
          { section = "keys", gap = 1, padding = 2 },
          { text = { "🚀 Done is better than perfect", hl = "SnacksDashboardFooter" }, align = "center" },
        },
      },
      indent = {
        indent = { char = "│" },
        scope = { enabled = false }, -- old ibl setup drew scope in the same colour, i.e. no visible scope
        animate = { enabled = false },
        filter = function(buf)
          local excluded = { help = true, oil = true, ["neo-tree"] = true, lazy = true, mason = true, toggleterm = true, trouble = true }
          return vim.bo[buf].buftype == "" and not excluded[vim.bo[buf].filetype] and vim.g.snacks_indent ~= false
        end,
      },
      input = { enabled = true }, -- vim.ui.input
      picker = {
        enabled = true,
        ui_select = true, -- vim.ui.select (legendary, code actions, etc.)
        sources = {
          explorer = {
            hidden = true, -- show dotfiles (toggle with H)
            layout = { layout = { position = "right", width = 30 } },
          },
        },
      },
      explorer = { replace_netrw = false }, -- `nvim .` keeps opening oil
      bufdelete = { enabled = true },
      lazygit = { enabled = true },
    },
  },
}
