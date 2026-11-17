-- "Viewed" marks for codediff.nvim reviews, like GitHub's Viewed checkbox.
--
-- A mark is tied to the exact content of both sides of a file's diff (git blob hashes), so it
-- disappears when the file changes (e.g. new commits on a PR) and the same diff stays marked
-- across reviews. Marks are saved per repo in stdpath("data")/codediff-viewed.json.
--
-- Uses some codediff internals (lifecycle, explorer tree); if a codediff update breaks this,
-- reviews keep working and only the marks stop.
local M = {}

local STORE_PATH = vim.fn.stdpath "data" .. "/codediff-viewed.json"
local store -- { [git_root] = { [mark_key] = os.time() } }

local function load_store()
  if store then
    return store
  end
  local f = io.open(STORE_PATH)
  if f then
    local ok, decoded = pcall(vim.json.decode, f:read "*a")
    f:close()
    store = ok and type(decoded) == "table" and decoded or {}
  else
    store = {}
  end
  return store
end

local function save_store()
  local f = io.open(STORE_PATH, "w")
  if f then
    f:write(vim.json.encode(store))
    f:close()
  end
end

---------------------------------------------------------------------------
-- Git blob hashes for each side of a file's diff
---------------------------------------------------------------------------
local function git(root, args)
  local r = vim.system(vim.list_extend({ "git", "-C", root }, args), { text = true }):wait()
  return r.code == 0 and r.stdout or nil
end

local tree_cache = {} -- [root .. rev] = { [path] = blob }, immutable per commit
local function tree_blobs(root, rev)
  local key = root .. "\0" .. rev
  if not tree_cache[key] then
    local map = {}
    for line in (git(root, { "ls-tree", "-r", "--full-tree", rev }) or ""):gmatch "[^\n]+" do
      local sha, path = line:match "^%d+ %a+ (%x+)\t(.+)$"
      if sha then
        map[path] = sha
      end
    end
    tree_cache[key] = map
  end
  return tree_cache[key]
end

local index_cache = {} -- [root] = { mtime = ..., map = { [path] = blob } }
local function index_blobs(root)
  local index_path = vim.trim(git(root, { "rev-parse", "--path-format=absolute", "--git-path", "index" }) or "")
  local stat = vim.uv.fs_stat(index_path)
  local mtime = stat and (stat.mtime.sec .. "." .. stat.mtime.nsec) or ""
  local cached = index_cache[root]
  if not cached or cached.mtime ~= mtime then
    local map = {}
    for line in (git(root, { "ls-files", "-s" }) or ""):gmatch "[^\n]+" do
      local sha, path = line:match "^%d+ (%x+) %d+\t(.+)$"
      if sha then
        map[path] = sha
      end
    end
    cached = { mtime = mtime, map = map }
    index_cache[root] = cached
  end
  return cached.map
end

local work_cache = {} -- [abs path] = { stamp = ..., sha = ... }
local function working_blob(root, path)
  local abs = root .. "/" .. path
  local stat = vim.uv.fs_stat(abs)
  if not stat then
    return "none"
  end
  local stamp = stat.mtime.sec .. "." .. stat.mtime.nsec .. ":" .. stat.size
  local cached = work_cache[abs]
  if not cached or cached.stamp ~= stamp then
    cached = { stamp = stamp, sha = vim.trim(git(root, { "hash-object", "--", path }) or "none") }
    work_cache[abs] = cached
  end
  return cached.sha
end

local function blob(root, side, path)
  if side == "WORKING" then
    return working_blob(root, path)
  elseif side == "INDEX" then
    return index_blobs(root)[path] or "none"
  end
  return tree_blobs(root, side)[path] or "none"
end

-- Which two versions a file's diff compares, mirroring codediff's explorer modes
local function sides(data, file)
  if data.base_revision then -- branch / merge-base / PR review
    return data.base_revision, data.target_revision or "WORKING"
  elseif file.group == "staged" then -- :CodeDiff, Staged Changes
    return "HEAD", "INDEX"
  end
  return "INDEX", "WORKING" -- :CodeDiff, Changes (incl. untracked)
end

local function mark_key(data, file)
  local root = data.git_root
  local left, right = sides(data, file)
  local left_path = file.old_path or file.path
  local added = file.status == "A" or file.status == "??"
  local left_blob = added and "none" or blob(root, left, left_path)
  local right_blob = file.status == "D" and "none" or blob(root, right, file.path)
  return table.concat({ file.path, left_blob, right_blob }, "|")
end

---------------------------------------------------------------------------
-- Session helpers
---------------------------------------------------------------------------
local function explorer_for(tabpage)
  local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
  if not ok then
    return nil
  end
  local view = lifecycle.get_panel_view(tabpage or vim.api.nvim_get_current_tabpage())
  if view and view.tree and view.data and view.data.git_root then
    return view
  end
end

-- Every file in the review in display order, including ones inside collapsed folders
local function all_files(explorer)
  local files = {}
  local function walk(node)
    for _, id in ipairs(node:get_child_ids() or {}) do
      local child = explorer.tree:get_node(id)
      if child and child.data then
        if child.data.type == "directory" or child.data.type == "group" then
          walk(child)
        elseif not child.data.type then
          files[#files + 1] = child
        end
      end
    end
  end
  for _, node in ipairs(explorer.tree:get_nodes()) do
    if node.data and not node.data.type then
      files[#files + 1] = node
    else
      walk(node)
    end
  end
  return files
end

local function is_viewed(explorer, file)
  local marks = load_store()[explorer.data.git_root]
  return marks ~= nil and marks[mark_key(explorer.data, file)] ~= nil
end

local function set_viewed(explorer, file, viewed)
  local s = load_store()
  local root = explorer.data.git_root
  s[root] = s[root] or {}
  s[root][mark_key(explorer.data, file)] = viewed and os.time() or nil
end

-- Move the explorer cursor to a file (expanding its folders) and open its diff.
-- codediff's own tree (codediff.ui.lib.tree) keeps the parent in _parent_id and the line in _line.
local function select_file(explorer, node)
  local tree = explorer.tree
  local parent_id = node._parent_id
  while parent_id do
    local parent = tree:get_node(parent_id)
    if not parent then
      break
    end
    parent:expand()
    parent_id = parent._parent_id
  end
  tree:render()
  if node._line and explorer.winid and vim.api.nvim_win_is_valid(explorer.winid) then
    vim.api.nvim_win_set_cursor(explorer.winid, { node._line, 0 })
  end
  explorer.on_file_select(node.data)
end

---------------------------------------------------------------------------
-- Actions
---------------------------------------------------------------------------

--- Toggle viewed for the file under the cursor (explorer) or the file being shown (diff panes).
--- Marking a file viewed jumps to the next unviewed file. On a folder, toggles every file in it.
function M.toggle(tabpage)
  local explorer = explorer_for(tabpage)
  if not explorer then
    return vim.notify("Not in a CodeDiff review", vim.log.levels.WARN)
  end

  local targets, current = {}, nil
  if vim.api.nvim_get_current_buf() == explorer.bufnr then
    local node = explorer.tree:get_node()
    if not node or not node.data or node.data.type == "group" then
      return
    end
    if node.data.type == "directory" then
      for _, f in ipairs(all_files(explorer)) do
        local dir = node.data.dir_path .. "/"
        if f.data.path:sub(1, #dir) == dir and f.data.group == node.data.group then
          targets[#targets + 1] = f
        end
      end
    else
      targets, current = { node }, node
    end
  else
    local sel = explorer.data.current_selection
    for _, f in ipairs(all_files(explorer)) do
      if sel and f.data.path == sel.path and f.data.group == sel.group then
        targets, current = { f }, f
      end
    end
  end
  if #targets == 0 then
    return
  end

  -- Folder with everything viewed -> unmark all, otherwise mark all
  local mark = false
  for _, f in ipairs(targets) do
    if not is_viewed(explorer, f.data) then
      mark = true
    end
  end
  for _, f in ipairs(targets) do
    set_viewed(explorer, f.data, mark)
  end
  save_store()
  explorer.tree:render()

  if not mark then
    return
  end
  -- Jump to the next unviewed file after this one (wrapping around)
  local files = all_files(explorer)
  local start = 0
  local anchor = current or targets[#targets]
  for i, f in ipairs(files) do
    if f.data.path == anchor.data.path and f.data.group == anchor.data.group then
      start = i
    end
  end
  for offset = 1, #files do
    local f = files[(start + offset - 1) % #files + 1]
    if not is_viewed(explorer, f.data) then
      return select_file(explorer, f)
    end
  end
  vim.notify(("All %d files viewed"):format(#files))
end

--- Clear every viewed mark for the current review's repo
function M.clear(tabpage)
  local explorer = explorer_for(tabpage)
  if not explorer then
    return vim.notify("Not in a CodeDiff review", vim.log.levels.WARN)
  end
  load_store()[explorer.data.git_root] = nil
  save_store()
  explorer.tree:render()
  vim.notify "Cleared viewed marks for this repo"
end

---------------------------------------------------------------------------
-- Explorer row formatters (official codediff hook)
---------------------------------------------------------------------------
local CHECK = "\u{f00c}" -- nf-fa-check

function M.file_formatter(ctx)
  local layout = require("codediff.ui.explorer.formatters").file(ctx)
  local explorer = explorer_for()
  if not explorer or not is_viewed(explorer, { path = ctx.path, old_path = ctx.old_path, group = ctx.group, status = ctx.status }) then
    return layout
  end
  -- Dim the name/path and put a check before the status letter
  for i = 2, #layout.left do
    for _, seg in ipairs(layout.left[i].segments) do
      seg.hl = "Comment"
    end
  end
  table.insert(layout.right, 1, { segments = { { text = CHECK .. " ", hl = "DiagnosticOk" } } })
  return layout
end

function M.group_formatter(ctx)
  local layout = require("codediff.ui.explorer.formatters").group(ctx)
  local explorer = explorer_for()
  if not explorer or not ctx.files or #ctx.files == 0 then
    return layout
  end
  local viewed = 0
  for _, f in ipairs(ctx.files) do
    if is_viewed(explorer, f) then
      viewed = viewed + 1
    end
  end
  layout.right = { { segments = { { text = ("%d/%d viewed "):format(viewed, #ctx.files), hl = viewed == #ctx.files and "DiagnosticOk" or "Comment" } } } }
  return layout
end

---------------------------------------------------------------------------
-- Keymaps
---------------------------------------------------------------------------

--- Hook codediff's view-keymap setup so the diff panes get `key` too. The mapping is claimed in
--- its own codediff keymap scope, so it's removed when a buffer leaves the review (your real file
--- buffers keep their normal mappings).
function M.setup(opts)
  local pane_key, explorer_key = opts.pane_key, opts.explorer_key

  local view_keymaps = require "codediff.ui.view.keymaps"
  local original = view_keymaps.setup_all_keymaps
  view_keymaps.setup_all_keymaps = function(tabpage, original_bufnr, modified_bufnr, is_explorer_mode, ...)
    original(tabpage, original_bufnr, modified_bufnr, is_explorer_mode, ...)
    if not is_explorer_mode then
      return
    end
    local lifecycle = require "codediff.ui.lifecycle"
    lifecycle.begin_keymap_scope(tabpage, "viewed")
    for _, buf in ipairs { original_bufnr, modified_bufnr } do
      if buf and vim.api.nvim_buf_is_valid(buf) then
        lifecycle.set_buf_keymap(tabpage, buf, "n", pane_key, function()
          M.toggle(tabpage)
        end, { desc = "CodeDiff: toggle viewed, jump to next unviewed", silent = true, nowait = true })
      end
    end
    lifecycle.end_keymap_scope(tabpage, "viewed")
  end

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "codediff-explorer",
    group = vim.api.nvim_create_augroup("codediff_viewed", { clear = true }),
    callback = function(args)
      vim.keymap.set("n", explorer_key, function()
        M.toggle()
      end, { buffer = args.buf, desc = "CodeDiff: toggle viewed, jump to next unviewed", nowait = true })
    end,
  })

  vim.api.nvim_create_user_command("CodeDiffViewedClear", function()
    M.clear()
  end, { desc = "Clear CodeDiff viewed marks for this repo" })
end

return M
