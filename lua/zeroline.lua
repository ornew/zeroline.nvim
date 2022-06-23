local M = {}

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

local function make_block(ctx, _, block)
  local t = type(block)
  local l = ''
  if t == 'function' then
    block = block()
    t = type(block)
  end
  if t == 'table' then
    if block.align then
      l = l .. ' %=%<'
    end
    if block.highlight then
      local th = type(block.highlight)
      if th == 'string' then
        l = l .. '%#' .. block.highlight .. '#'
      elseif th == 'function' then
        l = l .. '%#' .. block.highlight(ctx) .. '#'
      else
        l = l .. '%#' .. string(block.highlight) .. '#'
      end
    end
  end
  local m = block.margin or ctx.defaults.margin
  local o = block.group_opt or ''
  l = l .. '%' .. o .. '(' .. m[1]
  if t == 'table' then
    if block.text then
      local tt = type(block.text)
      if tt == 'function' then
        l = l .. block.text()
      elseif tt == 'string' then
        l = l .. block.text
      else
        l = l .. string(block.text)
      end
    elseif block.spans then
      local p = block.padding or ctx.defaults.padding
      l = l .. p[1]
      for i, span in pairs(block.spans) do
        l = l .. make_block(ctx, i, span)
        if next(block.spans, i) == nil then
          l = l .. p[3]
        else
          l = l .. p[2]
        end
      end
    end
  elseif t == 'string' then
    l = l .. block
  else
    l = l .. string(block)
  end
  return l .. m[2] .. '%)'
end

local function make_line(ctx, blocks)
  local l = ''
  for name, block in pairs(blocks) do
    l = l .. make_block(ctx, name, block)
  end
  return l
end

function M.init(user_config)
  local config = vim.deepcopy(defaults)
  config = vim.tbl_deep_extend('force', config, user_config)

  _G._lualine_state = {
    tabline = function()
      return make_line(config.context, config.tabline)
    end,
    statusline = {
      active = function()
        return make_line(config.context, config.statusline.active)
      end,
      inactive = function()
        return make_line(config.context, config.statusline.inactive)
      end,
    },
  }
  local group = vim.api.nvim_create_augroup('LuaLine', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
    group = group,
    pattern = { '*' },
    callback = function ()
      vim.wo.statusline = [[%!v:lua._lualine_state.statusline.active()]]
    end
  })
  vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave' }, {
    group = group,
    pattern = { '*' },
    callback = function ()
      vim.wo.statusline = [[%!v:lua._lualine_state.statusline.inactive()]]
    end
  })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'DirChanged' }, {
    group = group,
    pattern = { '*' },
    callback = function ()
      vim.o.tabline = [[%!v:lua._lualine_state.tabline()]]
    end
  })
end

M.setup = M.init

return M
