local M = {}

local uv = vim.uv or vim.loop

function M.setup(opts)
    vim.api.nvim_create_user_command("Usync", function()
        M.sync()
    end, {})
    local utils = require("uniutil.utils")
    M.unity_root = utils.find_unity_project_root()
    if not M.unity_root then
        return
    end

    local group = vim.api.nvim_create_augroup("uniutil", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        pattern = "*.cs",
        callback = function(args)
        end
    })
end

function M.sync()
    local utils = require("uniutil.utils")
    local xml2lua = require("uniutil.external.xml2lua")
    local xmlHandler = require("uniutil.external.xmlhandler.tree")
    if not M.unity_root then
        vim.notify("Not inside a Unity project", vim.log.levels.WARN)
        return
    end

    local asmdef = utils.find_asmdef(vim.fn.expand("%:p:h"), M.unity_root)
    local project_file = "Assembly-CSharp"
    if asmdef then
        local asmdef_data = utils.read_asmdef(asmdef)
        if asmdef_data and asmdef_data.name then
            project_file = asmdef_data.name
        end
    end

    local cs_project_path = uv.fs_realpath(M.unity_root .. "/" .. project_file .. ".csproj")
    if not cs_project_path then
        vim.notify("Could not find C# project file: " .. project_file .. ".csproj", vim.log.levels.ERROR)
        return
    end

    local file = io.open(cs_project_path, "r")
    if not file then
        vim.notify("Failed to open C# project file: " .. cs_project_path, vim.log.levels.ERROR)
        return
    end
    local content = file:read("*a")
    file:close()

    local parser = xml2lua.parser(xmlHandler)
    parser:parse(content)




    vim.print("Syncing C# project: " .. cs_project_path)
    vim.print("This is a unity project with root: " .. M.unity_root)
    vim.print("The relevant project file is: " .. project_file)
end

return M
