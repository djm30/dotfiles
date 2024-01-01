local M = {
  "folke/noice.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "mrded/nvim-lsp-notify",
    "rcarriga/nvim-notify",
  },
}

local border = "rounded"

M.config = function()
  require("notify").setup {
    background_colour = "none",
    timeout = 2000,
    stages = "static",
    top_down = false,
  }

  require("lsp-notify").setup {
    notify = require "notify",
  }

  require("noice").setup {
    lsp = {
      progress = {
        enabled = false,
      },
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },

    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
    views = {
      cmdline_popup = {
        position = {
          row = "60%",
        },
        border = {
          style = border,
          -- padding = { 1, 1 },
        },
        size = {
          width = 60,
          height = "auto",
        },
        filter_options = {},
        win_options = {
          winhighlight = {
            Normal = "NoiceCmdlinePopup",
            FloatBorder = "NoiceCmdlinePopupBorder",
            Title = "NoiceCmdlinePopupTitle",
          },
        },
      },
      popupmenu = {
        relative = "editor",
        position = {
          row = "82%",
          col = "50%",
        },
        size = {
          width = 60,
          height = 10,
        },
        border = {
          style = border,
          scrollbar = false,
          -- padding = { 1, 1 },
        },
        filter_options = {},
        win_options = {
          winhighlight = {
            Normal = "NoiceCmdlinePopup",
            FloatBorder = "NoiceCmdlinePopupBorder",
            Title = "NoiceCmdlinePopupTitle",
          },
        },
      },
    },
  }
end

return M
