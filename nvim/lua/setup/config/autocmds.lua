-- [[ Remove line numbers and enter insert mode when terminal is opened ]]
vim.cmd [[autocmd TermOpen * setlocal nonumber norelativenumber | startinsert]]

-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

-- [[ Wraps to next line when navigating horizontal ]]
vim.cmd "set whichwrap+=<,>,[,],h,l"

-- [[ Shows diagnostic info on hover]]
-- vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
