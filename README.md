# zeroline.nvim

Zeroline is a very small plugin for customizing statusline and tabline on NeoVim.

There are many status line plugins in the world. If you're happy with those, you won't need this plugin.

Zeroline does not limit the structure and the speed of the status line. You can place any. You can decide all from zero.

I don't really like statusline plugins because zero configurable and cool design plugins have limited structural extensibility or have overhead due to features I don't need. Zeroline provides the same extensibility as building a statusline from scratch, and about visual functionality only aids implementation.

In short, this plugin is for users who are willing to make every effort to optimize their status lines, and to eliminate waste is the user's mission :D

This plugin is built with pure Lua and will only work with relatively newer versions of NeoVim. At the cost of that compatibility, you can use any object on Vim (built-in functions like LSP, functions created by other plugins, etc.) and objects on Lua to create statusline.

## Usage

[vim-plug](https://github.com/junegunn/vim-plug)

```
Plug 'ornew/zeroline.nvim'
```

[jetpack](https://github.com/tani/vim-jetpack)

```
require('jetpack').setup {
  'ornew/zeroline.nvim',
}
```

### Setup

```lua
-- see SetupOptions
require('zeroline').setup {}
```

Zeroline only displays the file name by default. There is no cool UI.

```lua
local defaults = {
  context = {
    defaults = {
      padding = { '', '|', '' },
      margin = { ' ', ' ' },
    },
  },
  tabline = {},
  statusline = {
    active = { '%f' },
    inactive = { '%f' },
  },
}
```

```typescript
type Block = {
  text?: string | (() => string)
  highlight?: string | (() => string)
  margin?: [string, string]
  spans?: BlockLike[]
  align?: boolean
}

/*
  if a string is passed, it will be a text:
    'foo' == { text = 'foo' }
 */
type BlockLike = string | Block | (() => Block)

type SetupOptions = {
  /* an array of Blocks for a tabline. */
  tabline: BlockLike[]
  statusline: {
    /* an array of Blocks for an active window's statusline. */
    active: BlockLike[]

    /* an array of Blocks for an inactive window's statusline. */
    inactive: BlockLike[]
  }
}
```

## Examples

Basic:

```lua
require('zeroline').setup {
  statusline = {
    active = {
      '%f',
      {
        highlight = 'Red',
        text = '%{winnr()}',
      },
      function()
        return {
          align = true,
          spans = {
            '%3pl:%-2c',
          },
        }
      end,
    },
  },
}
```

Show git head revision with Fugitive:

```lua
require'zeroline'.setup {
  statusline = {
    active = {
      { text = vim.fn['FugitiveHead'] },
    },
  },
}
```

Show tabs with cwd:

```lua
local function get_cwd()
  return vim.api.nvim_call_function('fnamemodify', { '.', ':p' })
end

local function get_tabs_block()
  local l = ''
  local ts = vim.api.nvim_list_tabpages()
  local c = vim.api.nvim_get_current_tabpage()
  for i, t in ipairs(ts) do
    local n = ' ' .. t .. ' '
    if t == c then
      l = l .. '%#TabLineSel#' .. '%' .. i .. 'T' .. n
    else
      l = l .. '%#TabLine#' .. '%' .. i .. 'T' .. n
    end
  end
  return {
    text = l .. '%#TabLineFill#%T',
  }
end

require'zeroline'.setup {
  tabline = {
    { text = get_cwd },
    get_tabs_block,
  },
}
```

Show by a condition:

TBW

Show a current mode:

```lua
local function termcode(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- :help mode()
local mode_map = {
  n = {
    text = 'NORMAL',
    highlight = 'ModeNormal',
  },
  i = {
    text = 'INSERT',
    highlight = 'ModeInsert',
  },
  [termcode'<C-v>'] = {
    text = 'VISUAL BLOCK',
    highlight = 'ModeVisualBlock',
  },
  t = {
    text = 'TERMINAL',
    highlight = 'ModeTerminal',
  },
}

local function get_mode_block()
  local m = vim.api.nvim_get_mode().mode
  local o = mode_map[m] or {
    text = m,
    highlight = 'ModeUnknown',
  }
  return o
end

require'zeroline'.setup {
  statusline = {
    active = {
      get_mode_block,
    },
  },
}
```

Show builtin LSP informations:

TBW
