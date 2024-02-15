local opts_with_desc = require("setup.config.util").opts_with_desc

function CLOSE_BUFFER_WITHOUT_CLOSING_WINDOW(buf)
  -- Switch to the next buffer
  vim.cmd "bnext"

  -- If the buffer after switching is the same as the current, open a new one
  if vim.api.nvim_get_current_buf() == buf then
    vim.cmd "enew"
  end

  -- Delete the original buffer
  vim.cmd("bd! " .. buf)
end

local function close_buffer_without_closing_window()
  -- Get the current buffer number

  local current_buf = vim.api.nvim_get_current_buf()

  CLOSE_BUFFER_WITHOUT_CLOSING_WINDOW(current_buf)
end

local function close_others()
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()

  for _, buf in ipairs(buffers) do
    if buf ~= current_buf and vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_is_valid(buf) then
      local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
      if filetype ~= "neo-tree" then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end
end

local function close_all()
  close_others()
  close_buffer_without_closing_window()
end

-- Close Current Buffer
vim.keymap.set("n", "<leader>xx", close_buffer_without_closing_window, opts_with_desc "Close current buffer")

-- Close Current Window
vim.keymap.set("n", "<leader>xw", ":wa | close<CR>", opts_with_desc "Save all and close current window")

-- Close other buffers than the active one
vim.keymap.set("n", "<leader>xo", close_others, opts_with_desc "Closes all other buffers")

-- Close All Buffers
vim.keymap.set("n", "<leader>xa", close_all, opts_with_desc "Close all buffers")
-- vim.keymap.set("n", "<leader>xa", ": wa | %bd|e#|bd#<CR>", opts_with_desc "Close all buffers")

-- Close Quickfix List
vim.keymap.set("n", "<leader>xq", ":cclose<CR>", opts_with_desc "Close quickfix list")

-- Close Current Split (Vertically/Horizontally)
vim.keymap.set("n", "<leader>xv", ":vclose<CR>", opts_with_desc "Close current vertical split")
vim.keymap.set("n", "<leader>xh", ":close<CR>", opts_with_desc "Close current horizontal split")

-- Save All Buffers and Force Quit NeoVim
vim.keymap.set("n", "<leader>xfqa", ":wa | qa!<CR>", opts_with_desc "Save all and force quit NeoVim")
vim.keymap.set("n", "<leader>xfqb", ":wa | bd!<CR>", opts_with_desc "Saves and force quits buffer")
