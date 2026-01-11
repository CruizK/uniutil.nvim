# Unity Utils Neovim (WIP)

A collection of helper utilities for working with Unity projects in Neovim.

This is super WIP, so use at your own risk.

## Features

`:Usync` command
This will synchronize the C# files in the unity project to their respect .csproj files.
This respects the assembly definitions and will update the correct one. Haven't tested this with Editor scripts, so currently the Editor/ folder is just ignored

Snippets 

All snippets that setup classes will respect the namespace based on the asmdef's "rootNamespace" JSON field.

`bk` - Creates a baker class (Namespace)
`mb` - Creates a monobehaviour class (Namespace)


## Installing
```lua
{
  "CruizK/uniutil.nvim",
  config = function()
    require("uniutil").setup {
      include_snippets = true -- If you want snippets
    }
  end,
  ft = "cs"
}
```
