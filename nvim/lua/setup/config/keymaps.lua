local opts_with_desc = require("setup.config.util").opts_with_desc
local opts = require("setup.config.util").opts

local keymap = vim.keymap.set

-- Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("n", "<leader>e", ":Neotree toggle<CR>", opts_with_desc "Toggles Filetree")

-- Remap for dealing with word wrap
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

keymap("n", "<leader>sv", ":vs", opts_with_desc "Splits Vertically")
keymap("n", "<leader>sh", ":split", opts_with_desc "Splits Horizontally")

-- IDK what Q does but it doesn't do anything now
keymap("n", "Q", "<nop>", opts)

-- Replaces current word with something else, like cmd d in vscode
keymap("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], opts_with_desc "Replaces current word")

-- Keeps cursor at start of current line when moving text from below to current line
keymap("n", "J", "mzJ`z", opts)
-- Keeps cursor centered when scrolling
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

keymap("n", "<leader>tv", "ToggleTerm direction=vertical", opts_with_desc "Vertical terminal")
keymap("n", "<leader>th", "ToggleTerm direction=horizontal", opts_with_desc "Vertical terminal")

-- Keeps cursor centered when searching
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Copies selection to system clipboard
keymap({ "n", "v" }, "<leader>y", [["+y]], opts_with_desc "Copies to clipboard")

-- Copies from cursor pos to end of line to system clipboard
keymap("n", "<leader>Y", [["+Y]], opts_with_desc "Copies to end of line to clipboard")

-- Deletes selection without copying? Need a better key combo for it
-- keymap({"n", "v"}, "<leader>", [["_d]], opts)

-- Insert --
-- Press jj fast to enter
keymap("i", "jj", "<ESC>", opts)

-- Visual --
-- Stay in v mode when indenting
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down, matches indenting
keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

-- Paste with saving removed text to the buffer
keymap("v", "p", '"_dP', opts)
-- mapped to leader p instead, might enable this later im not sure
-- keymap("x", "<leader>p", [["_dP]], opts)

-- Terminal --
-- Better terminal navigation
local term_opts = { silent = true }
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
keymap("t", "<Esc>", [[<C-\><C-n>]], opts)
-- Slows down lazygit
-- keymap("t", "jk", [[<C-\><C-n>]], opts)

-- Create a new vertical terminal without line numbers
vim.cmd [[
  command! -nargs=0 VTerm vnew | setlocal nonumber | term
]]

-- Map <leader>t v to the VTerm command
keymap("n", "<leader>tv", ":VTerm<CR>", opts_with_desc "New vertical terminal")

-- Create a new horizontal terminal without line numbers
vim.cmd [[
  command! -nargs=0 HTerm new | setlocal nonumber | term
]]

-- Map <leader>t h to the HTerm command
keymap("n", "<leader>th", ":HTerm<CR>", opts_with_desc "New horizontal terminal")
