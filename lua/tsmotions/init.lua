
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

-- <Plugin> mappings
vim.keymap.set('n', '<Plug>(MoveToNextId)', function() M.NextTypeName() end, { noremap = true }   )
vim.keymap.set('n', '<Plug>(MoveToPrevId)', function() M.PrevTypeName() end, { noremap = true }   )

return M
