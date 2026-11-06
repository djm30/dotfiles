-- Neotest: run tests from the file you're in. Adapters auto-detect the framework per project
-- (jest/vitest from package.json, pytest, go test, rspec, phpunit, plenary).
-- neotest-jest claims every *.test.* file; only let it handle projects that actually use Jest
-- (otherwise it fights neotest-vitest in Vitest projects).
local function uses_jest(file_path)
  local root = vim.fs.root(file_path, "package.json")
  if not root then
    return false
  end
  if vim.fs.find(function(name)
    return name:match "^jest%.config%."
  end, { path = root, limit = 1 })[1] then
    return true
  end
  -- Plain Lua IO: neotest calls this from an async context where vim.fn is not allowed
  local f = io.open(root .. "/package.json", "r")
  if not f then
    return false
  end
  local ok, pkg = pcall(vim.json.decode, f:read "*a")
  f:close()
  if not ok or type(pkg) ~= "table" then
    return false
  end
  return pkg.jest ~= nil
    or (pkg.dependencies or {}).jest ~= nil
    or (pkg.devDependencies or {}).jest ~= nil
    or (pkg.scripts and pkg.scripts.test and pkg.scripts.test:match "jest") ~= nil
end

local function neotest(fn)
  return function()
    fn(require "neotest")
  end
end

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",

      -- Adapters
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-python",
      "fredrikaverpil/neotest-golang",
      "nvim-neotest/neotest-plenary",
      "olimorris/neotest-rspec",
      "olimorris/neotest-phpunit",
    },
    keys = {
      { "<leader>tn", neotest(function(n) n.run.run() end), desc = "Test nearest" },
      { "<leader>tf", neotest(function(n) n.run.run(vim.fn.expand "%") end), desc = "Test file" },
      { "<leader>tl", neotest(function(n) n.run.run_last() end), desc = "Run last test" },
      { "<leader>ts", neotest(function(n) n.run.run(vim.uv.cwd()) end), desc = "Test suite (cwd)" },
      { "<leader>td", neotest(function(n) n.run.run { strategy = "dap" } end), desc = "Debug nearest test" },
      { "<leader>tx", neotest(function(n) n.run.stop() end), desc = "Stop tests" },
      { "<leader>to", neotest(function(n) n.output.open { enter = true, auto_close = true } end), desc = "Test output (float)" },
      { "<leader>tO", neotest(function(n) n.output_panel.toggle() end), desc = "Test output panel" },
      { "<leader>tS", neotest(function(n) n.summary.toggle() end), desc = "Test summary tree" },
      { "<leader>twn", neotest(function(n) n.watch.toggle() end), desc = "Watch nearest test" },
      { "<leader>twf", neotest(function(n) n.watch.toggle(vim.fn.expand "%") end), desc = "Watch file" },
      { "<leader>tws", neotest(function(n) n.watch.stop() end), desc = "Stop watching" },
      { "]T", neotest(function(n) n.jump.next { status = "failed" } end), desc = "Next failed test" },
      { "[T", neotest(function(n) n.jump.prev { status = "failed" } end), desc = "Previous failed test" },
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require "neotest-jest" {
            isTestFile = function(file_path)
              return file_path ~= nil
                and require("neotest-jest.jest-util").defaultIsTestFile(file_path)
                and uses_jest(file_path)
            end,
          },
          require "neotest-vitest" {},
          require "neotest-python" { dap = { justMyCode = false } },
          require "neotest-golang" {},
          require "neotest-plenary",
          require "neotest-rspec",
          require "neotest-phpunit",
        },
        consumers = {
          -- Pop up a "N passed, M failed" notification when a run finishes
          summary_notify = function(client)
            client.listeners.results = function(adapter_id, results, partial)
              if partial then
                return
              end
              local counts = { passed = 0, failed = 0, skipped = 0 }
              for pos_id, result in pairs(results) do
                local node = client:get_position(pos_id, { adapter = adapter_id })
                if node and node:data().type == "test" and counts[result.status] then
                  counts[result.status] = counts[result.status] + 1
                end
              end
              if counts.passed + counts.failed + counts.skipped == 0 then
                return
              end
              local msg = ("\u{f058} %d passed   \u{f057} %d failed"):format(counts.passed, counts.failed)
              if counts.skipped > 0 then
                msg = msg .. ("   %d skipped"):format(counts.skipped)
              end
              vim.schedule(function()
                vim.notify(msg, counts.failed > 0 and vim.log.levels.ERROR or vim.log.levels.INFO, { title = "Tests" })
              end)
            end
            return {}
          end,
        },
        -- Failures show inline as diagnostics on the failing line
        diagnostic = { enabled = true, severity = vim.diagnostic.severity.ERROR },
        status = { virtual_text = true, signs = true },
        output = { open_on_run = false },
        quickfix = { open = false },
        log_level = vim.log.levels.WARN,
        icons = {
          passed = "\u{f058}", -- nf-fa-check_circle
          running = "\u{f10c}", -- nf-fa-circle_o
          failed = "\u{f057}", -- nf-fa-times_circle
          unknown = "\u{f059}", -- nf-fa-question_circle
          skipped = "\u{eabd}",
        },
        floating = { border = "rounded", max_height = 0.8, max_width = 0.9 },
      }
    end,
  },
}
