# zeroline.nvim

Zeroline is a very small plugin for customizing statusline and tabline on NeoVim.

There are many status line plugins in the world. If you're happy with those, you won't need this plugin.

Zeroline does not limit the structure and the speed of the status line. You can place any. You can decide all from zero.

This plugin is built with pure Lua and will only work with relatively newer versions of NeoVim. At the cost of that compatibility, you can use any object on Vim (built-in functions like LSP, functions created by other plugins, etc.) and objects on Lua to create statusline.

## Usage

[vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'ornew/zeroline.nvim'
```

[jetpack](https://github.com/tani/vim-jetpack)

```lua
require('jetpack').setup {
  'ornew/zeroline.nvim',
}
```

### Setup

```lua
local zl = require('zeroline')
zl.setup {}
```

Zeroline only displays the file name by default. There is no cool UI.

## Examples

Basic:

```lua
local h = zl.h

require'zeroline'.setup {
  statusline = {
    h { fmt = { margin = 1 } } '%{winnr()} %f',
  },
}
```

Show git head revision with Fugitive:

```lua
require'zeroline'.setup {
  statusline = {
    h {} (vim.fn['FugitiveHead']),
  },
}
```

Show tabs with cwd on tabline:

```lua
local function get_cwd()
  return vim.api.nvim_call_function('fnamemodify', { '.', ':p:~' })
end

local function get_tabs()
  local l = ''
  local ts = vim.api.nvim_list_tabpages()
  local c = vim.api.nvim_get_current_tabpage()
  for i, t in ipairs(ts) do
    local n = ' ' .. t .. ' '  -- get_tab_fname(t)
    if t == c then
      l = l .. '%#TabLineSel#' .. '%' .. i .. 'T' .. n
    else
      l = l .. '%#TabLine#' .. '%' .. i .. 'T' .. n
    end
  end
  return l .. '%#TabLineFill#%T'
end

require'zeroline'.setup {
  tabline = {
    h { fmt = { margin = 1, highlight = 'Orange' } } (get_cwd),
    h {} (get_tabs),
  },
}
```

Show by a condition:

```lua
local if_ = zl.if_

local function actived()
  return vim.api.nvim_win_get_var(0, 'window_is_active')
end

require'zeroline'.setup {
  statusline = {
    if_(actived) {
      h { fmt = { highlight = 'Blue' } } '%{winnr()} %f',
    }:else_ {
      h { fmt = { highlight = 'Gray' } } '%{winnr()} %f',
    },
  },
}
```

Show filename adjusted the format by a window width:

```lua
local function get_file_path()
  local opt = ':.'
  if vim.api.nvim_win_get_width(0) < 120 then
    opt = opt .. ':t'
  end
  local p = vim.api.nvim_call_function('fnamemodify', { vim.fn.expand('%'), opt})
  if #p > 50 then
    p = vim.fn.pathshorten(p)
  end
  return p
end

require'zeroline'.setup {
  statusline = {
    h { group = { max_width = 50 } } (get_file_path),
  },
}
```

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

local function get_mode_name()
  local m = vim.api.nvim_get_mode().mode
  return (mode_map[m] or {}).text or m
end

local function get_mode_highlight()
  local m = vim.api.nvim_get_mode().mode
  return (mode_map[m] or {}).highlight or 'ModeUnknown'
end

require'zeroline'.setup {
  statusline = {
    if_(actived) {
      h { fmt = { highlight = get_mode_highlight } } (get_mode_name),
    },
  },
}
```

Show builtin LSP informations:

TBW
