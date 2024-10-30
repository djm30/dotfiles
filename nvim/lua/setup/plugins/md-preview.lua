local M = {
  -- Manual install script
  -- cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app
  -- ./install.sh
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
}

return M
