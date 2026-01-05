local ls = require('luasnip')
local s = ls.s
local t = ls.t
local i = ls.i
local d = ls.d
local sn = ls.sn
local isn = ls.indent_snippet_node
local fmt = require('luasnip.extras.fmt').fmt

ls.cleanup()

--- Helper function to wrap a snippet in a namespace
--- @param inner fun(): LuaSnip.Node The snippet function to wrap
--- @return LuaSnip.Node d_node A dynamic snippet node wrapped in a namespace
local function wrap_namespace(inner)
  return d(1, function(args)
    return sn(nil, {
      t({ 'namespace InferredNamespace', '{', '\t' }),
      isn(1, inner(), '\t'),
      t({ '', '}' })
    })
  end)
end

ls.add_snippets('cs', {
  s('ns', wrap_namespace(function()
    return fmt(
      [[
        public class {}
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
  s('mb',
    vim.list_extend(
      fmt(
        [[
            public class {} : MonoBehaviour
            {{

                private void Start()
                {{
                    {}
                }}

                private void Update()
                {{

                }}

            }}
        ]],
        {
          i(1, 'ClassName'),
          i(0),
        }
      ),
      fmt(
        [[
          // Some ending comment {}
        ]],
        {
          i(2, 'EndComment'),
        }
      )
    )
  ),
}, {})
