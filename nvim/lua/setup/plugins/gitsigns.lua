local M = {
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  "lewis6991/gitsigns.nvim",
}

M.config = function()
  require("gitsigns").setup {

    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      map("n", "<leader>gb", function()
        gs.blame_line { full = true }
      end)
      map("n", "<leader>gtb", gs.toggle_current_line_blame)
      map("n", "<leader>gd", gs.diffthis)
      map("n", "<leader>gtd", gs.toggle_deleted)

      -- map("n", "<leader>hD", function()
      --   gs.diffthis "~"
      -- end)
    end,
  }
end

return M
