local M = {}

local is_win = vim.fn.has("win32")

--- Updates a .csproj to have the correct <Compile> nodes
--- This makes the assumption that there is only every one <ItemGroup> that contains all <Compile> nodes
--- If there are no compile nodes, it will use the first empty <ItemGroup> it finds
--- @param csproj_path string Path to the .csproj file
--- @param files string[] All files associated with the project
function M.update_csproj_file(csproj_path, files)
  local compile_lines = {}
  local lines = vim.fn.readfile(csproj_path)

  local first = 0
  local last = 0
  for i, line in ipairs(lines) do
    if line:match('<Compile%s+Include%s*=%s*"(.-)"%s*/>') then
      first = i
      break
    end
  end

  if first ~= 0 then
    for i = first, 0, -1 do
      if lines[i]:match('<ItemGroup>') then
        first = i
        break
      end
    end

    for i = first, #lines do
      if lines[i]:match('</ItemGroup>') then
        last = i - 1
        break
      end
    end
  end

  if first == 0 then
    vim.notify(
      "No <Compile> nodes found in "
      .. csproj_path
      .. " will attempt to use first empty ItemGroup",
      vim.log.levels.WARN
    )
    -- If we don't find any compile nodes, use the first empty ItemGroup instead
    for i, line in ipairs(lines) do
      if line:match('<ItemGroup>') and lines[i + 1]:match('</ItemGroup>') then
        first = i
        last = i
        break
      end
    end
  end

  table.insert(compile_lines, '    <!-- Auto-generated Compile nodes from UniUtil -->')

  for _, path in ipairs(files) do
    table.insert(compile_lines, M.compile_node(path, vim.fs.dirname(csproj_path)))
  end

  table.insert(compile_lines, '    <!-- End Auto-generated Compile nodes from UniUtil -->')

  local start = vim.list_slice(lines, 0, first)
  local final = vim.list_slice(lines, last + 1, #lines)


  vim.list_extend(start, compile_lines)
  vim.list_extend(start, final)

  vim.fn.writefile(start, csproj_path)
end

--- Creates a compile node XML string for a given file path
--- @param path string The file path to include
--- @param root string The root directory to relativize the path against
--- @return string The XML string for the compile node
function M.compile_node(path, root)
  local relpath = vim.fs.relpath(root, path)
  assert(relpath, "Path cannot be nil")
  if is_win then
    relpath = string.gsub(relpath, '/', '\\')
  end
  return '    <Compile Include="' .. relpath .. '" />'
end

return M
