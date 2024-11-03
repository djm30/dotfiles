-- TODO: Finish configuring debugging for node
return {
  "mfussenegger/nvim-dap", -- Debug Adapter Protocol for Neovim
  lazy = true,
  dependencies = {
    "theHamsta/nvim-dap-virtual-text", -- help to find variable definitions in debug mode
    "rcarriga/nvim-dap-ui", -- Nice UI for nvim-dap
    "suketa/nvim-dap-ruby", -- Debug Ruby
    "mfussenegger/nvim-dap-python", -- Debug Python
  },
  init = function()
    require("legendary").keymaps {
      {
        itemgroup = "Debug",
        description = "Debugging functionality...",
        icon = "",
        keymaps = {
          {
            "<F1>",
            "<cmd>lua require('dap').toggle_breakpoint()<CR>",
            description = "Set breakpoint",
          },
          { "<F2>", "<cmd>lua require('dap').continue()<CR>", description = "Continue" },
          { "<F3>", "<cmd>lua require('dap').step_into()<CR>", description = "Step into" },
          { "<F4>", "<cmd>lua require('dap').step_over()<CR>", description = "Step over" },
          {
            "<F5>",
            "<cmd>lua require('dap').repl.toggle({height = 6})<CR>",
            description = "Toggle REPL",
          },
          { "<F6>", "<cmd>lua require('dap').repl.run_last()<CR>", description = "Run last" },
          {
            "<F9>",
            function()
              local _, dap = require "dap"
              dap.disconnect()
              require("dapui").close()
            end,
            description = "Stop",
          },
        },
      },
    }
  end,
  config = function()
    local dap = require "dap"
    require("dap-ruby").setup()
    require("dap-python").setup "~/.virtualenvs/debugpy/bin/python"

    ---Show the nice virtual text when debugging
    ---@return nil|function
    local function virtual_text_setup()
      local ok, virtual_text = pcall(require, "nvim-dap-virtual-text")
      if not ok then
        return
      end

      return virtual_text.setup()
    end

    ---Show custom virtual text when debugging
    ---@return nil
    local function signs_setup()
      vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DebugBreakpoint",
        linehl = "",
        numhl = "DebugBreakpoint",
      })
      vim.fn.sign_define("DapStopped", {
        text = "",
        texthl = "DebugHighlight",
        linehl = "",
        numhl = "DebugHighlight",
      })
    end

    ---Slick UI which is automatically triggered when debugging
    ---@param adapter table
    ---@return nil
    local function ui_setup(adapter)
      local ok, dapui = pcall(require, "dapui")
      if not ok then
        return
      end

      dapui.setup {
        layouts = {
          {
            elements = {
              "scopes",
              "breakpoints",
              "stacks",
            },
            size = 35,
            position = "left",
          },
          {
            elements = {
              "repl",
            },
            size = 0.30,
            position = "bottom",
          },
        },
      }
      adapter.listeners.after.event_initialized["dapui_config"] = dapui.open
      adapter.listeners.before.event_terminated["dapui_config"] = dapui.close
      adapter.listeners.before.event_exited["dapui_config"] = dapui.close
    end

    dap.set_log_level "TRACE"

    virtual_text_setup()
    signs_setup()
    ui_setup(dap)
  end,
}
