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
    -- - stage file, <leader>hs/<leader>hr stage/discard hunk, g? help, q close.
    -- Viewed marks (setup/codediff_viewed.lua): v in the file list / <leader>gv in a diff marks the
    -- file viewed and jumps to the next unviewed one. gf opens the file in a normal tab;
    -- <leader>gd / <leader>gD jump back to the open review.
    "esmuellert/codediff.nvim",
    cmd = { "CodeDiff", "CodeDiffViewedClear" },
    keys = function()
      -- Switch to an open review tab instead of starting another one. A review whose file list
      -- window is gone (e.g. its windows were switched to other buffers) is closed instead.
      local function focus_review()
        local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
        if not ok then
          return false
        end
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
          if lifecycle.get_session(tab) then
            local view = lifecycle.get_panel_view(tab)
            local intact = view
              and view.winid
              and vim.api.nvim_win_is_valid(view.winid)
              and vim.api.nvim_win_get_buf(view.winid) == view.bufnr
            if intact then
              vim.api.nvim_set_current_tabpage(tab)
              return true
            end
            if #vim.api.nvim_list_tabpages() > 1 then
              vim.cmd("tabclose " .. vim.api.nvim_tabpage_get_number(tab))
            end
          end
        end
        return false
      end
      return {
        {
          "<leader>gd",
          function()
            if not focus_review() then
              vim.cmd "CodeDiff"
            end
          end,
          desc = "CodeDiff: review uncommitted changes (or back to open review)",
        },
        {
          "<leader>gD",
          function()
            if focus_review() then
              return
            end
            -- Compare against the repo's default branch (main/master), including uncommitted work
            local ref = vim.fn.systemlist("git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null")[1]
            local base = (ref and ref ~= "") and ref:gsub("^origin/", "") or "main"
            vim.cmd("CodeDiff " .. base)
          end,
          desc = "CodeDiff: review branch vs default branch (or back to open review)",
        },
      }
    end,
    opts = {
      diff = { layout = "inline" }, -- single pane with deletions shown inline (`t` switches to side-by-side)
      -- <Tab>/<S-Tab> move between files inside a review (globally they're :bnext/:bprev, which
      -- would swap the review's windows to other buffers and break it)
      keymaps = { view = { next_file = { "]f", "<Tab>" }, prev_file = { "[f", "<S-Tab>" } } },
      explorer = {
        view_mode = "tree", -- folders in the file list (`i` switches to flat list)
        formatters = {
          file = function(ctx)
            return require("setup.codediff_viewed").file_formatter(ctx)
          end,
          group = function(ctx)
            return require("setup.codediff_viewed").group_formatter(ctx)
          end,
        },
      },
    },
    config = function(_, opts)
      -- Before codediff's setup: its side-by-side view keeps a reference to the keymap function we wrap
      require("setup.codediff_viewed").setup { explorer_key = "v", pane_key = "<leader>gv" }
      require("codediff").setup(opts)
    end,
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
