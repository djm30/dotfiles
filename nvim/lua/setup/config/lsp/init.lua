local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require "setup.config.lsp.mason"
require("setup.config.lsp.handlers").setup()
-- require "setup.config.lsp.null-ls"
