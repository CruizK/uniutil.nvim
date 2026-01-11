local M = {}

--- Finds the root directory of a Unity project, starts in CWD
--- @return string|nil root The path to the Unity project root or nil if not found
function M.find_unity_project_root()
  local root = vim.fs.root(vim.fn.getcwd(), { "Assets" })
  return root
end

--- Finds and reads closest .asmdef to file
--- @param file string The path to the .asmdef file
--- @param root? string|nil The root to stop looking upward
--- @return table|nil The parsed asmdef data or nil if failed
function M.get_asmdef(file, root)
  root = root or M.find_unity_project_root()
  local asmdef_path = vim.fs.find(function(name, _)
    return name:match('%.asmdef$')
  end, { path = file, upward = true, type = "file", stop = root })[1]
  if not asmdef_path then
    return nil
  end
  local asmdef = io.open(asmdef_path, "r")
  if not asmdef then
    vim.notify("Failed to open asmdef file: " .. asmdef_path, vim.log.levels.ERROR)
    return
  end
  local content = asmdef:read("*a")
  asmdef:close()
  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    vim.notify("Failed to parse asmdef file: " .. asmdef, vim.log.levels.ERROR)
    return
  end
  return data
end

return M
