-- Use the project's virtualenv so imports from installed packages resolve:
-- an activated $VIRTUAL_ENV first, then .venv/ or venv/ in the project root (uv, poetry in-project, python -m venv).
local function project_python(root)
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. "/bin/python"
  end
  for _, dir in ipairs { ".venv", "venv" } do
    local python = root and (root .. "/" .. dir .. "/bin/python")
    if python and vim.uv.fs_stat(python) then
      return python
    end
  end
end

return {
  before_init = function(_, config)
    local python = project_python(config.root_dir)
    if python then
      config.settings.python.pythonPath = python
    end
  end,
  settings = {
    pyright = {
      disableOrganizeImports = true, -- ruff handles imports
    },
    python = {
      analysis = {
        typeCheckingMode = "off",
      },
    },
  },
}
