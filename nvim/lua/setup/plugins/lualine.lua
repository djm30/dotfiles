local M = {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "olimorris/onedarkpro.nvim",
  },
}
local function show_macro_recording()
  local recording_register = vim.fn.reg_recording()
  if recording_register == "" then
    return ""
  else
    return "Recording @" .. recording_register
  end
end

local function show_root_dir()
  local cwd = vim.fn.getcwd()
  local match = cwd:match "^.+/(.+)$"
  return "󰉖 /" .. match
end

M.config = function()
  local onedarkpro = require "setup.config.colourscheme.onedarkpro_lualine"

  require("lualine").setup {
    options = {
      theme = onedarkpro,
      disabled_filetypes = { "neo-tree" },
      globalstatus = true,
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { "filename" },
      lualine_x = {
        {
          "macro-recording",
          fmt = show_macro_recording,
        },
        "filetype",
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },

    tabline = {
      lualine_a = { show_root_dir },
      lualine_b = { "filetype", "filename" },
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = { "buffers" },
    },
  }

  local lualine = require "lualine"

  vim.api.nvim_create_autocmd("RecordingEnter", {
    callback = function()
      lualine.refresh {
        place = { "statusline" },
      }
    end,
  })

  vim.api.nvim_create_autocmd("RecordingLeave", {
    callback = function()
      -- This is going to seem really weird!
      -- Instead of just calling refresh we need to wait a moment because of the nature of
      -- `vim.fn.reg_recording`. If we tell lualine to refresh right now it actually will
      -- still show a recording occuring because `vim.fn.reg_recording` hasn't emptied yet.
      -- So what we need to do is wait a tiny amount of time (in this instance 50 ms) to
      -- ensure `vim.fn.reg_recording` is purged before asking lualine to refresh.
      local timer = vim.loop.new_timer()
      timer:start(
        50,
        0,
        vim.schedule_wrap(function()
          lualine.refresh {
            place = { "statusline" },
          }
        end)
      )
    end,
  })
end

return M
