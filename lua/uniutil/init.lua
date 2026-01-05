local M = {}

local config = require("uniutil.config")

---@param opts? uniutil.Opts
function M.setup(opts)
  config.setup(opts)

  vim.api.nvim_create_user_command("Usync", function()
    M.sync_files()
  end, {})


  if config.include_snippets then
    require("uniutil.snippets")
  end
end

function M.sync_files()
  local utils = require("uniutil.utils")
  local xml = require("uniutil.xml")
  local root = utils.find_unity_project_root()
  if not root then
    vim.notify("Not inside a Unity project", vim.log.levels.WARN)
    return
  end

  local asset_path = vim.fs.joinpath(root, "Assets")

  local cs_files = vim.fn.globpath(asset_path, "**/*.cs", false, true)
  local asmdef_files = vim.fn.globpath(asset_path, "**/*.asmdef", false, true)

  --- @type table<string, string>
  local asmdefs = {}

  -- Find all asmdef files and parse them, the name should equate to the csproj name
  for _, path in ipairs(asmdef_files) do
    local f = io.open(path, "r")
    if not f then
      vim.notify("Failed to open asmdef file: " .. path, vim.log.levels.ERROR)
      return
    end
    local content = f:read("*a")
    f:close()
    local ok, data = pcall(vim.json.decode, content)
    if not ok then
      vim.notify("Failed to parse asmdef file: " .. path, vim.log.levels.ERROR)
      return
    end
    asmdefs[data.name] = vim.fs.dirname(path)
  end

  --- @type table<string, string[]>
  local csproj_to_files = {}

  -- Associate each C# file with the correct csproj based on asmdef location
  for _, file_path in ipairs(cs_files) do
    local csproj_path = vim.fs.joinpath(root, "Assembly-CSharp.csproj")
    local ignore = false

    for _, ignore_folder in ipairs(config.ignore_folders) do
      if vim.fs.normalize(file_path):match(ignore_folder) then
        ignore = true
        break
      end
    end

    if not ignore then
      for asmdef_name, asmdef_path in pairs(asmdefs) do
        if vim.fs.relpath(asmdef_path, file_path) then
          csproj_path = vim.fs.joinpath(root, asmdef_name .. ".csproj")
          break
        end
      end
      if not csproj_to_files[csproj_path] then
        csproj_to_files[csproj_path] = {}
      end
      table.insert(csproj_to_files[csproj_path], file_path)
    end
  end

  for csproj_path, files in pairs(csproj_to_files) do
    xml.update_csproj_file(csproj_path, files)
  end
end

return M
