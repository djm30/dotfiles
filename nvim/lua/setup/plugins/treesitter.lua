-- nvim-treesitter `main` branch (the old `master` branch is frozen and breaks on Neovim 0.12).
-- `main` only installs parsers/queries; highlighting, folds and selection are built into Neovim.
-- Requires the `tree-sitter` CLI (brew install tree-sitter-cli).
local ensure_installed = {
  "c",
  "go",
  "lua",
  "python",
  "rust",
  "tsx",
  "javascript",
  "typescript",
  "html",
  "css",
  "vimdoc",
  "vim",
  "bash",
  "svelte",
  "json",
  "yaml",
  "markdown",
  "markdown_inline",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- the plugin doesn't support lazy-loading
    build = ":TSUpdate",
    config = function()
      local ts = require "nvim-treesitter"
      ts.install(ensure_installed)

      local available = {}
      for _, lang in ipairs(ts.get_available()) do
        available[lang] = true
      end

      local function start(buf, lang)
        if not pcall(vim.treesitter.start, buf, lang) then
          return
        end
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      -- Start highlighting + indent for every buffer with a parser; auto-install missing ones
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("setup-treesitter", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then
            return
          end
          if vim.treesitter.language.add(lang) then
            start(args.buf, lang)
          elseif available[lang] then
            ts.install(lang):await(function()
              if vim.api.nvim_buf_is_valid(args.buf) then
                start(args.buf, lang)
              end
            end)
          end
        end,
      })

      -- Incremental selection (same keys as before) using Neovim 0.12's built-in `an`/`in`
      vim.keymap.set("n", "<C-space>", "van", { remap = true, desc = "Start node selection" })
      vim.keymap.set("x", "<C-space>", "an", { remap = true, desc = "Grow node selection" })
      vim.keymap.set("x", "<M-space>", "in", { remap = true, desc = "Shrink node selection" })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup {
        select = { lookahead = true }, -- jump forward to the next text object
        move = { set_jumps = true },
      }

      local select = require "nvim-treesitter-textobjects.select"
      for keys, obj in pairs {
        aa = "@parameter.outer",
        ia = "@parameter.inner",
        af = "@function.outer",
        ["if"] = "@function.inner",
        ac = "@class.outer",
        ic = "@class.inner",
      } do
        vim.keymap.set({ "x", "o" }, keys, function()
          select.select_textobject(obj, "textobjects")
        end, { desc = "Select " .. obj })
      end

      local move = require "nvim-treesitter-textobjects.move"
      for keys, spec in pairs {
        ["]m"] = { "goto_next_start", "@function.outer" },
        ["]]"] = { "goto_next_start", "@class.outer" },
        ["]M"] = { "goto_next_end", "@function.outer" },
        ["]["] = { "goto_next_end", "@class.outer" },
        ["[m"] = { "goto_previous_start", "@function.outer" },
        ["[["] = { "goto_previous_start", "@class.outer" },
        ["[M"] = { "goto_previous_end", "@function.outer" },
        ["[]"] = { "goto_previous_end", "@class.outer" },
      } do
        vim.keymap.set({ "n", "x", "o" }, keys, function()
          move[spec[1]](spec[2], "textobjects")
        end, { desc = spec[1]:gsub("_", " ") .. " " .. spec[2] })
      end
    end,
  },

  {
    -- Auto close/rename HTML & JSX tags
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}
