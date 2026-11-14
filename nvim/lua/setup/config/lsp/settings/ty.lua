-- ty (Astral) finds the project's .venv / $VIRTUAL_ENV itself.
--
-- Type checking stays "off" like before: only undefined names and unresolved imports are reported
-- (the "add import" quick fix hangs off the undefined-name error). Editor settings override a
-- project's own ty config, so this limit is only applied when the project doesn't configure ty.
local function project_configures_ty(root)
  if not root then
    return false
  end
  if vim.uv.fs_stat(root .. "/ty.toml") or vim.uv.fs_stat(root .. "/.ty.toml") then
    return true
  end
  local f = io.open(root .. "/pyproject.toml")
  if not f then
    return false
  end
  local content = f:read "*a"
  f:close()
  return content:find("%[tool%.ty[%].]") ~= nil
end

return {
  before_init = function(_, config)
    if not project_configures_ty(config.root_dir) then
      config.settings.ty.configuration = {
        rules = {
          all = "ignore",
          ["unresolved-reference"] = "error",
          ["unresolved-import"] = "error",
        },
      }
    end
  end,
  settings = {
    ty = {
      inlayHints = { variableTypes = false, callArgumentNames = false }, -- keep the buffer clean
    },
  },
}
