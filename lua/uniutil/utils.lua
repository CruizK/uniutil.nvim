local utils = {}

--- Finds the root directory of a Unity project, starts in CWD
--- @return string|nil The path to the Unity project root or nil if not found
function utils.find_unity_project_root()
    local root = vim.fs.root(vim.fn.getcwd(), { "Assets" })
    return root
end

--- Finds the nearest .asmdef file
--- @param start string The starting directory to search from
--- @return string|nil The path to the .asmdef file or nil if not found
function utils.find_asmdef(start, root)
    local f = vim.fs.find(function(name, path)
        return name:match('%.asmdef$')
    end, { path = start, upward = true, type = "file", stop = root })[1]
    if f then
        return f
    else
        return nil
    end
end

--- Reads and parses a .asmdef file
--- @param asmdef string The path to the .asmdef file
--- @return table|nil The parsed asmdef data or nil if failed
function utils.read_asmdef(asmdef)
    local file = io.open(asmdef, "r")
    if not file then
        vim.notify("Failed to open asmdef file: " .. asmdef, vim.log.levels.ERROR)
        return
    end
    local content = file:read("*a")
    file:close()
    local ok, data = pcall(vim.json.decode, content)
    if not ok then
        vim.notify("Failed to parse asmdef file: " .. asmdef, vim.log.levels.ERROR)
        return
    end
    return data
end

return utils
