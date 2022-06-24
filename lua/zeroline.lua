local M = {}

local function h(props)
  return function(children)
    local t = type(children)
    local n = {
      props = props or {},
    }
    if t == 'string' then n.text = children
    elseif t == 'function' then n.render = function(_) return children() end
    else n.children = children end
    return n
  end
end

local function defn(fnable)
  if type(fnable) == 'function' then
    return fnable()
  end
  return fnable
end

local function group(opt)
  local b0 = {}
  local b1 = {}
  table.insert(b0, '%')
  if opt.align_left and defn(opt.align_left) then
    table.insert(b0, '-')
  end
  if opt.min_width then
    table.insert(b0, defn(opt.min_width))
  end
  if opt.max_width then
    table.insert(b0, '.' .. defn(opt.max_width))
  end
  table.insert(b0, '(')
  table.insert(b1, '%)')
  return {
    pre = table.concat(b0),
    post = table.concat(b1),
  }
end

local function fmt(opt)
  local b0 = {}
  local b1 = {}
  local m = { 0, 0 }
  local p = { 0, 0 }
  if opt.margin then
    m = defn(opt.margin)
    if type(m) == 'number' then
      m = { m, m }
    end
  end
  if opt.padding then
    p = defn(opt.padding)
    if type(p) == 'number' then
      p = { p, p }
    end
  end
  table.insert(b0, string.rep(' ', m[1]))
  local hi = defn(opt.highlight)
  if hi then
    table.insert(b0, '%#' .. hi .. '#')
  end
  table.insert(b0, string.rep(' ', p[1]))
  table.insert(b1, string.rep(' ', p[2]))
  local hir = defn(opt.reset_highlight)
  if hir then
    table.insert(b1, '%#' .. hir .. '#')
  end
  table.insert(b1, string.rep(' ', m[2]))
  return {
    pre = table.concat(b0),
    post = table.concat(b1),
  }
end

local function render(node)
  local o = {}
  if not node then
    return ''
  end
  local g = nil
  if node.props and node.props.group then
    g = group(defn(node.props.group))
    table.insert(o, g.pre)
  end
  local f = nil
  if node.props and node.props.fmt then
    f = fmt(defn(node.props.fmt))
    table.insert(o, f.pre)
  end
  if node.text then
    table.insert(o, node.text)
  elseif node.render then
    table.insert(o, node:render())
  elseif node.children then
    for _, v in ipairs(node.children) do
      table.insert(o, render(v))
    end
  else
    -- fragments
    for _, v in ipairs(node) do
      table.insert(o, render(v))
    end
  end
  if f then
    table.insert(o, f.post)
  end
  if g then
    table.insert(o, g.post)
  end
  return table.concat(o)
end

local function render_cond(cond_node)
  if cond_node.data.cond() then
    return render(cond_node.data.true_case)
  else
    return render(cond_node.data.false_case)
  end
end

function M.if_(cond)
  return function(true_case)
    local n = {
      name = 'Cond',
      data = {
        cond = cond,
        true_case = true_case,
        false_case = nil,
      },
      render = render_cond,
    }
    n.else_ = function(self, false_case)
      self.data.false_case = false_case
      return self
    end
    return n
  end
end

local defaults = {
  tabline = {},
  statusline = {
    h {} '%f',
  },
}
local config = {}

function M.setup(user_config)
  config = vim.tbl_deep_extend('force', defaults, user_config)
  M.reset()
end

function M.reset()
  _G.ZeroLineStatusLine = function(active)
    local c = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_var(0, 'window_is_active', active)
    return render(config.statusline)
  end
  _G.ZeroLineTabLine = function()
    return render(config.tabline)
  end
  local group = vim.api.nvim_create_augroup('ZeroLine', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
    group = group,
    pattern = { '*' },
    callback = function ()
      vim.wo.statusline = [[%!v:lua.ZeroLineStatusLine(v:true)]]
    end
  })
  vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave' }, {
    group = group,
    pattern = { '*' },
    callback = function ()
      vim.wo.statusline = [[%!v:lua.ZeroLineStatusLine(v:false)]]
    end
  })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'DirChanged' }, {
    group = group,
    pattern = { '*' },
    callback = function ()
      vim.o.tabline = [[%!v:lua.ZeroLineTabLine()]]
    end
  })
end

M.h = h
M.render = render

return M
