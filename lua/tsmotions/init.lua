
local M = require('tsmotions.core')

-- User commands
vim.api.nvim_create_user_command(
	'TMNextTypeName',
	function(opts)
		M.NextTypeName( opts.fargs[1] )
	end,
	{ nargs = 1}
)

vim.api.nvim_create_user_command(
	'TMPrevTypeName',
	function(opts)
		M.PrevTypeName( opts.fargs[1] )
	end,
	{ nargs = 1}
)

vim.api.nvim_create_user_command(
	'TMNextQuery',
	function(opts)
		M.NextQuery( opts.fargs[1] )
	end,
	{ nargs = 1}
)

vim.api.nvim_create_user_command(
	'TMPrevQuery',
	function(opts)
		M.PrevQuery( opts.fargs[1] )
	end,
	{ nargs = 1}
)

return M
