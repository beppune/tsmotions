
local M = require('tsmotions')
print("User Commands")
vim.api.nvim_user_command(
	'TMNextTypeName',
	function(opts)
		M.NextTypeName( opts.fargs[1] )
	end,
	{ nargs = 1}
)

vim.api.nvim_user_command(
	'TMPrevTypeName',
	function(opts)
		M.PrevTypeName( opts.fargs[1] )
	end,
	{ nargs = 1}
)

