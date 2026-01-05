local default_config = {
  ignore_folders = { "/Editor/" },
  include_snippets = true,
}


local M = {}

---@param opts? uniutil.Opts
function M.setup(opts)
  opts = opts or {}
  local newconf = vim.tbl_deep_extend("force", default_config, opts)
  for k, v in pairs(newconf) do
    M[k] = v
  end
end

---@class (exact) uniutil.Config
---@field setup fun(opts?: uniutil.Opts)
---@field ignore_folders string[] List of patterns to ignore under Assets/ , defaults to just "/Editor/"
---@field include_snippets boolean Whether to include unity snippets via LuaSnip
---
---@class (exact) uniutil.Opts
---@field ignore_folders? string[] List of patterns to ignore under Assets/ , defaults to just "/Editor/"
---@field include_snippets? boolean Whether to include unity snippets via LuaSnip


---@cast M uniutil.Config
return M
