local ls = require('luasnip')
local s = ls.s
local t = ls.t
local i = ls.i
local d = ls.d
local sn = ls.sn
local isn = ls.indent_snippet_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep


--- Helper function to wrap a snippet in a namespace which is inferred from the asmdef
--- @param inner fun(): LuaSnip.Node The snippet function to wrap
--- @param usings? string[] A list of using directives to include at the top
--- @return LuaSnip.Node d_node A dynamic snippet node wrapped in a namespace
local function wrap_namespace(inner, usings)
  return d(1, function(args)
    local utils = require('uniutil.utils')
    local asmdef = utils.get_asmdef(vim.fn.expand('%:p'))
    if asmdef and asmdef.rootNamespace ~= '' then
      return sn(nil, {
        t({ 'namespace ' .. asmdef.rootNamespace, '{', '\t' }),
        isn(1, inner(), '\t'),
        t({ '', '}' })
      })
    end

    return sn(nil, inner())
  end)
end

ls.add_snippets('cs', {
  s('mb', wrap_namespace(function()
    return fmt(
      [[
        using UnityEngine;

        public class {} : MonoBehaviour
        {{
            void Start()
            {{
                {}
            }}
        }}
      ]],
      {
        i(1, 'ClassName'),
        i(2)
      }
    )
  end)),
  s('bk', wrap_namespace(function()
    return fmt(
      [[
        using UnityEngine;
        using Unity.Entities;

        public class {}Authoring : MonoBehaviour
        {{
            public class {}Baker : Baker<{}Authoring>
            {{
                public override void Bake({}Authoring authoring)
                {{
                    {}
                }}
            }}
        }}
      ]],
      {
        i(1, 'Class'),
        rep(1),
        rep(1),
        rep(1),
        i(2)
      }
    )
  end))
}, {})
