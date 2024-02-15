local M = {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    -- Typescript debugging
    {
      "mxsdev/nvim-dap-vscode-js",
    },
  },
}

local function configure_typescript()
  require("dap-vscode-js").setup {
    -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
    debugger_path = vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter",
    -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
    adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
    -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
    -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
    -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
  }

  for _, language in ipairs { "typescript", "javascript" } do
    require("dap").configurations[language] = {
      {
        name = "Launch",
        type = "pwa-node",
        request = "launch",
        program = "${file}",
        rootPath = "${workspaceFolder}",
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        skipFiles = { "<node_internals>/**" },
        protocol = "inspector",
        console = "integratedTerminal",
      },
      {
        name = "Attach to node process",
        type = "pwa-node",
        request = "attach",
        rootPath = "${workspaceFolder}",
        processId = require("dap.utils").pick_process,
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug Jest Tests",
        -- trace = true, -- include debugger info
        runtimeExecutable = "node",
        runtimeArgs = {
          "./node_modules/jest/bin/jest.js",
          "--runInBand",
        },
        rootPath = "${workspaceFolder}",
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
      },
    }
  end
end

M.config = function()
  require("dapui").setup()
  local opts_with_desc = require("setup.config.util").opts_with_desc

  local dap, dapui = require "dap", require "dapui"

  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
  end
  dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
  end

  vim.keymap.set("n", "<Leader>b", ":DapToggleBreakpoint<CR>", opts_with_desc "Toggle breakpoint on current line")
  vim.keymap.set("n", "<F5>", ":DapContinue<CR>", opts_with_desc "Debug - Continue")
  vim.keymap.set("n", "<F4>", ":DapTerminate<CR>", opts_with_desc " Debug - Terminate")
  vim.keymap.set("n", "<F10>", ":DapStepOver<CR>", opts_with_desc "Debug - Step Over")
  vim.keymap.set("n", "<F11>", ":DapStepInto<CR>", opts_with_desc "Debug - Step Into")

  configure_typescript()
end

return M
