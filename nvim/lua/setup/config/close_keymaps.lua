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

function CLOSE_ALL_BUFFERS_EXCEPT_NEOTREE()
  -- Retrieve a list of all buffer numbers
  local buffers = vim.api.nvim_list_bufs()

  -- Iterate over each buffer
  for _, buf in ipairs(buffers) do
    -- Get the file type of the buffer
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")

    -- Check if the buffer is not a NeoTree buffer
    if filetype ~= "neo-tree" then
      -- Check if the buffer is valid and loaded
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
        -- Get the number of windows displaying the buffer
        local windows = vim.fn.count(vim.api.nvim_list_wins(), function(win_id)
          return vim.api.nvim_win_get_buf(win_id) == buf
        end)

        -- If the buffer is the last in its window, open a new unnamed buffer
        if windows == 1 then
          vim.api.nvim_command("sbuffer " .. buf)
          vim.api.nvim_command "enew"
        end

        -- Delete the buffer without closing the window
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end
end

-- Close Current Buffer
vim.keymap.set("n", "<leader>xb", close_buffer_without_closing_window, opts_with_desc "Close current buffer")
vim.keymap.set("n", "<leader>xx", close_buffer_without_closing_window, opts_with_desc "Close current buffer")

vim.keymap.set(
  "n",
  "<leader>xo",
  ":wa | BufferLineCloseOthers<CR>",
  opts_with_desc "Close all other buffers than the active one"
)

-- Close Current Window
vim.keymap.set("n", "<leader>xw", ":wa | close<CR>", opts_with_desc "Save all and close current window")

-- Close All Buffers
-- vim.keymap.set("n", "<leader>xa", ": wa | %bd|e#|bd#<CR>", opts_with_desc "Close all buffers")
vim.keymap.set("n", "<leader>xa", CLOSE_ALL_BUFFERS_EXCEPT_NEOTREE, opts_with_desc "Close all buffers")

-- Close Quickfix List
vim.keymap.set("n", "<leader>xq", ":cclose<CR>", opts_with_desc "Close quickfix list")

-- Close Current Split (Vertically/Horizontally)
vim.keymap.set("n", "<leader>xv", ":vclose<CR>", opts_with_desc "Close current vertical split")
vim.keymap.set("n", "<leader>xh", ":close<CR>", opts_with_desc "Close current horizontal split")

-- Save All Buffers and Force Quit NeoVim
vim.keymap.set("n", "<leader>xfqa", ":wa | qa!<CR>", opts_with_desc "Save all and force quit NeoVim")
vim.keymap.set("n", "<leader>xfqb", ":wa | bd!<CR>", opts_with_desc "Saves and force quits buffer")
