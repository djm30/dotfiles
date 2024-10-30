local opts_with_desc = require("setup.config.util").opts_with_desc
local opts = require("setup.config.util").opts
local move_with_count = require("setup.config.util").move_with_count

local keymap = vim.keymap.set

-- Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Normal --

-- Make i match current line indent
vim.cmd [[function! IndentWithI()
    if len(getline('.')) == 0
        return "\"_cc"

    else
        return "i"
    endif


endfunction
nnoremap <expr> i IndentWithI()]]

local toolbox = require "legendary.toolbox"

local keymaps = {
  -- Better arrow key navigation
  {
    "<Down>",
    function()
      move_with_count "j"
    end,
    description = "Move down",
  },
  {
    "<Up>",
    function()
      move_with_count "k"
    end,
    description = "Move up",
  },
  {
    "<Left>",
    function()
      move_with_count "h"
    end,
    description = "Move left",
  },
  {
    "<Right>",
    function()
      move_with_count "l"
    end,
    description = "Move right",
  },

  -- Buffer navigation
  { "<Tab>", ":bnext<CR>", description = "Next buffer" },
  { "<S-Tab>", ":bprev<CR>", description = "Previous buffer" },
  { "<S-l>", ":bnext<CR>", description = "Next buffer (alternate)" },
  { "<S-h>", ":bprevious<CR>", description = "Previous buffer (alternate)" },
  { "<C-n>", ":bnext<CR>", description = "Next buffer (ctrl)" },
  { "<C-m>", ":bprevious<CR>", description = "Previous buffer (ctrl)" },

  -- Save on Enter
  { "<CR>", ":w<CR>", description = "Save file" },

  -- Window navigation
  {
    itemgroup = "window_navigation",
    description = "Window Navigation Commands",
    icon = "🪟",
    keymaps = {
      { "<C-h>", "<C-w>h", description = "Move to left window" },
      { "<C-j>", "<C-w>j", description = "Move to bottom window" },
      { "<C-k>", "<C-w>k", description = "Move to top window" },
      { "<C-l>", "<C-w>l", description = "Move to right window" },
      { "<S-Left>", "<C-w>h", description = "Move to left window (arrows)" },
      { "<S-Down>", "<C-w>j", description = "Move to bottom window (arrows)" },
      { "<S-Up>", "<C-w>k", description = "Move to top window (arrows)" },
      { "<S-Right>", "<C-w>l", description = "Move to right window (arrows)" },
    },
  },

  -- File tree
  { "<leader>v", ":Neotree toggle<CR>", description = "Toggle Filetree" },
  { "<leader>e", ":Neotree focus<CR>", description = "Focus Filetree" },

  -- Word wrap navigation
  {
    "k",
    "v:count == 0 ? 'gk' : 'k'",
    description = "Move up (respecting wrap)",
    opts = { expr = true, silent = true },
  },
  {
    "j",
    "v:count == 0 ? 'gj' : 'j'",
    description = "Move down (respecting wrap)",
    opts = { expr = true, silent = true },
  },

  -- Window resizing
  {
    itemgroup = "window_resize",
    description = "Window Resizing Commands",
    icon = "↕️",
    keymaps = {
      { "<A-k>", ":resize +2<CR>", description = "Increase height" },
      { "<A-j>", ":resize -2<CR>", description = "Decrease height" },
      { "<A-h>", ":vertical resize -2<CR>", description = "Decrease width" },
      { "<A-l>", ":vertical resize +2<CR>", description = "Increase width" },
      { "<A-Up>", ":resize +2<CR>", description = "Increase height (arrows)" },
      { "<A-Down>", ":resize -2<CR>", description = "Decrease height (arrows)" },
      { "<A-Left>", ":vertical resize -2<CR>", description = "Decrease width (arrows)" },
      { "<A-Right>", ":vertical resize +2<CR>", description = "Increase width (arrows)" },
    },
  },

  -- Splits
  { "<leader>sv", ":vs<CR>", description = "Split vertically" },
  { "<leader>sh", ":split<CR>", description = "Split horizontally" },

  -- Surrounds
  { "(", { x = "S)" }, hide = true, description = "Surround with ()'s", opts = { remap = true } },
  { ")", { x = "S)" }, hide = true, description = "Surround with ()'s", opts = { remap = true } },
  { "{", { x = "S}" }, hide = true, description = "Surround with {}'s", opts = { remap = true } },
  { "}", { x = "S}" }, hide = true, description = "Surround with {}'s", opts = { remap = true } },
  { "[", { x = "S]" }, hide = true, description = "Surround with []'s", opts = { remap = true } },
  { "]", { x = "S]" }, hide = true, description = "Surround with []'s", opts = { remap = true } },

  -- Disable Q
  { "Q", "<nop>", description = "Disable Q" },

  -- Replace current word
  {
    "<leader>r",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    description = "Replace current word",
  },

  -- Cursor positioning
  { "J", "mzJ`z", description = "Join lines keeping cursor position" },
  { "<C-d>", "<C-d>zz", description = "Scroll down keeping cursor centered" },
  { "<C-u>", "<C-u>zz", description = "Scroll up keeping cursor centered" },

  -- Terminal
  {
    itemgroup = "terminal",
    description = "Terminal Commands",
    icon = "🖥️",
    keymaps = {
      { "<leader>tv", ":VTerm<CR>", description = "New vertical terminal" },
      { "<leader>th", ":HTerm<CR>", description = "New horizontal terminal" },
      {
        mode = "t",
        "<C-h>",
        "<C-\\><C-N><C-w>h",
        description = "Move to left window from terminal",
        opts = { silent = true },
      },
      {
        mode = "t",
        "<C-j>",
        "<C-\\><C-N><C-w>j",
        description = "Move to bottom window from terminal",
        opts = { silent = true },
      },
      {
        mode = "t",
        "<C-k>",
        "<C-\\><C-N><C-w>k",
        description = "Move to top window from terminal",
        opts = { silent = true },
      },
      {
        mode = "t",
        "<C-l>",
        "<C-\\><C-N><C-w>l",
        description = "Move to right window from terminal",
        opts = { silent = true },
      },
      {
        mode = "t",
        "nn",
        [[<C-\><C-n>]],
        description = "Exit terminal mode",
      },
    },
  },

  -- Search
  { "n", "nzzzv", description = "Next search result (centered)" },
  { "N", "Nzzzv", description = "Previous search result (centered)" },

  -- Clipboard operations
  {
    itemgroup = "clipboard",
    description = "Clipboard Operations",
    icon = "📋",
    keymaps = {
      {
        "<leader>y",
        [["+y]],
        description = "Copy to system clipboard",
        mode = { "n", "v" },
      },
      {
        "<leader>Y",
        function()
          vim.fn.setreg("+", vim.fn.getreg "0")
        end,
        description = "Put last yank in system clipboard",
        mode = { "n", "v" },
      },
    },
  },

  -- Visual mode indenting
  {
    "<",
    "<gv",
    description = "Indent left and stay in visual mode",
    mode = "v",
  },
  {
    ">",
    ">gv",
    description = "Indent right and stay in visual mode",
    mode = "v",
  },

  -- Move text in visual mode
  {
    "J",
    ":m '>+1<CR>gv=gv",
    description = "Move text down",
    mode = "v",
  },
  {
    "K",
    ":m '<-2<CR>gv=gv",
    description = "Move text up",
    mode = "v",
  },

  -- Visual block mode text movement
  {
    "J",
    ":move '>+1<CR>gv-gv",
    description = "Move text down",
    mode = "x",
  },
  {
    "K",
    ":move '<-2<CR>gv-gv",
    description = "Move text up",
    mode = "x",
  },

  -- Paste without saving to buffer
  {
    "p",
    '"_dP',
    description = "Paste without saving removed text",
    mode = "v",
  },
}

return keymaps
