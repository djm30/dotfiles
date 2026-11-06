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
        { "<leader>a", group = "agents (orca)" },
        { "<leader>c", group = "code" },
        { "<leader>g", group = "git" },
        { "<leader>gt", group = "git toggles" },
        { "<leader>s", group = "split / search" },
        { "<leader>t", group = "test / terminal" },
        { "<leader>tw", group = "test watch" },
        { "<leader>r", group = "refactor / replace" },
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
    opts = {
      diff = { layout = "inline" }, -- single pane with deletions shown inline (`t` switches to side-by-side)
      explorer = { view_mode = "tree" }, -- folders in the file list (`i` switches to flat list)
    },
  },

  {
    -- Drive Orca (onorca.dev) worktrees and agents from Neovim via the `orca` CLI
    "PannenetsF/orca-ctl.nvim",
    main = "orcactl",
    cmd = {
      "Orca",
      "OrcaFind",
      "OrcaSwitchProject",
      "OrcaSwitchWorktree",
      "OrcaSwitchAgent",
      "OrcaWorktrees",
      "OrcaSend",
      "OrcaPrompt",
      "OrcaOutput",
      "OrcaScreen",
      "OrcaWait",
      "OrcaAgentNew",
    },
    keys = {
      { "<leader>ao", "<cmd>Orca<cr>", desc = "Orca: explorer" },
      { "<leader>af", "<cmd>OrcaFind<cr>", desc = "Orca: find worktree or agent" },
      { "<leader>ap", "<cmd>OrcaSwitchProject<cr>", desc = "Orca: switch project" },
      { "<leader>aw", "<cmd>OrcaSwitchWorktree<cr>", desc = "Orca: switch worktree" },
      { "<leader>aa", "<cmd>OrcaSwitchAgent<cr>", desc = "Orca: switch agent" },
      { "<leader>as", ":OrcaSend<cr>", mode = "x", desc = "Orca: send selection to agent" },
      { "<leader>aO", "<cmd>OrcaOutput<cr>", desc = "Orca: follow agent output" },
    },
    opts = { agent = "pi" }, -- command used by :OrcaAgentNew
  },
}
