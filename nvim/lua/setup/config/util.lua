local opts = { noremap = true, silent = true }

local function opts_with_desc(desc)
  return {
    noremap = opts.noremap,
    silent = opts.silent,
    desc = desc,
  }
end

local function move_with_count(key)
  local count = vim.v.count1
  vim.cmd("normal! " .. count .. key)
end

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

return {
  opts_with_desc = opts_with_desc,
  opts = opts,
  move_with_count = move_with_count,
  close_buffer_without_closing_window = close_buffer_without_closing_window,
  close_others = close_others,
  close_all = close_all,
}
