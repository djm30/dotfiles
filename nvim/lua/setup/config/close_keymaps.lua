local opts_with_desc = require("setup.config.util").opts_with_desc

local function close_buffer_without_closing_window()
  -- Get the current buffer number
  local current_buf = vim.api.nvim_get_current_buf()

  -- Switch to the next buffer
  vim.cmd "bnext"

  -- If the buffer after switching is the same as the current, open a new one
  if vim.api.nvim_get_current_buf() == current_buf then
    vim.cmd "enew"
  end

  -- Delete the original buffer
  vim.cmd("bd! " .. current_buf)
end

-- Close Current Buffer
vim.keymap.set("n", "<leader>xb", close_buffer_without_closing_window, opts_with_desc "Close current buffer")

vim.keymap.set(
  "n",
  "<leader>xo",
  ":wa | BufferLineCloseOthers<CR>",
  opts_with_desc "Close all other buffers than the active one"
)

-- Close Current Window
vim.keymap.set("n", "<leader>xw", ":wa | close<CR>", opts_with_desc "Save all and close current window")

-- Close All Buffers
vim.keymap.set("n", "<leader>xa", ":%bd|e#|bd#<CR>", opts_with_desc "Close all buffers")

-- Close Quickfix List
vim.keymap.set("n", "<leader>xq", ":cclose<CR>", opts_with_desc "Close quickfix list")

-- Close Current Split (Vertically/Horizontally)
vim.keymap.set("n", "<leader>xv", ":vclose<CR>", opts_with_desc "Close current vertical split")
vim.keymap.set("n", "<leader>xh", ":close<CR>", opts_with_desc "Close current horizontal split")

-- Save All Buffers and Force Quit NeoVim
vim.keymap.set("n", "<leader>xfqa", ":wa | qa!<CR>", opts_with_desc "Save all and force quit NeoVim")
