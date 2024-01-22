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

return {
  opts_with_desc = opts_with_desc,
  opts = opts,
  move_with_count = move_with_count,
}
