 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#11122d',
    base01 = '#1c1e4a',
    base02 = '#191b43',
    base03 = '#606270',
    base04 = '#afafb6',
    base05 = '#f2f2f3',
    base06 = '#f2f2f3',
    base07 = '#f2f2f3',
    base08 = '#fd4663',
    base09 = '#c666cc',
    base0A = '#925cd6',
    base0B = '#676ee4',
    base0C = '#e496e9',
    base0D = '#9398ec',
    base0E = '#ba96e9',
    base0F = '#910017',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#f2f2f3',          bg = '#11122d' })
  hi('TelescopeBorder',         { fg = '#606270',             bg = '#11122d' })
  hi('TelescopePromptNormal',   { fg = '#f2f2f3',          bg = '#11122d' })
  hi('TelescopePromptBorder',   { fg = '#606270',             bg = '#11122d' })
  hi('TelescopePromptPrefix',   { fg = '#676ee4',             bg = '#11122d' })
  hi('TelescopePromptCounter',  { fg = '#afafb6',  bg = '#11122d' })
  hi('TelescopePromptTitle',    { fg = '#11122d',             bg = '#676ee4' })
  hi('TelescopePreviewTitle',   { fg = '#11122d',             bg = '#925cd6' })
  hi('TelescopeResultsTitle',   { fg = '#11122d',             bg = '#c666cc' })
  hi('TelescopeSelection',      { fg = '#f2f2f3',          bg = '#191b43' })
  hi('TelescopeSelectionCaret', { fg = '#676ee4',             bg = '#191b43' })
  hi('TelescopeMatching',       { fg = '#676ee4',             bold = true })
end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
   vim.schedule_wrap(function()
     package.loaded['matugen'] = nil
     require('matugen').setup()
   end)
 )

 return M
