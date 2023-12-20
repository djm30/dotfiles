local M = {
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  "lewis6991/gitsigns.nvim",
  opts = {
    -- See `:help gitsigns.txt`
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    on_attach = function(bufnr)
      local gs = require "gitsigns"

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Toggles
      map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
      map("n", "<leader>td", gs.toggle_deleted, { desc = "toggle git show deleted" })

      -- Text object
    end,
  },
}

return M
