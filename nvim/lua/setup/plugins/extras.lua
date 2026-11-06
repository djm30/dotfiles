return {
  {
    -- Project-wide search & replace with live preview (uses ripgrep)
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open()
        end,
        desc = "Search & replace (project)",
      },
      {
        "<leader>sr",
        function()
          require("grug-far").with_visual_selection()
        end,
        mode = "x",
        desc = "Search & replace selection",
      },
      {
        "<leader>sw",
        function()
          require("grug-far").open { prefills = { search = vim.fn.expand "<cword>" } }
        end,
        desc = "Search & replace word under cursor",
      },
    },
    opts = {},
  },

  {
    -- Renders markdown in the buffer (replaces markdown-preview's browser window)
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>m", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown rendering", ft = "markdown" },
    },
    opts = {},
  },

  {
    -- Popup showing available keys after a prefix like <leader>
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 400,
      spec = {
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "split / search" },
        { "<leader>t", group = "terminal / todo" },
        { "<leader>r", group = "refactor" },
      },
    },
  },

  {
    -- Review all changed files with VSCode-style diffs; auto-refreshes while an agent edits.
    -- In the review tab: ]f/[f files, ]c/[c changes, t inline/side-by-side, gc fold unchanged,
    -- - stage file, <leader>hs/<leader>hr stage/discard hunk, gf open file, g? help, q close.
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    keys = {
      { "<leader>gd", "<cmd>CodeDiff<cr>", desc = "Review uncommitted changes" },
      {
        "<leader>gD",
        function()
          -- Compare against the repo's default branch (main/master), including uncommitted work
          local ref = vim.fn.systemlist("git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null")[1]
          local base = (ref and ref ~= "") and ref:gsub("^origin/", "") or "main"
          vim.cmd("CodeDiff " .. base)
        end,
        desc = "Review branch changes vs default branch",
      },
    },
    opts = {},
  },
}
