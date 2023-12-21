local M = {
  "ahmedkhalf/project.nvim",
}

M.config = function()
  require("project_nvim").setup()
end

return M
