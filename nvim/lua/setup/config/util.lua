local opts = { noremap = true, silent = true }
local function opts_with_desc(desc)
  return {
    noremap = opts.noremap,
    silent = opts.silent,
    desc = desc,
  }
end

return {
  opts_with_desc = opts_with_desc,
  opts = opts,
}
