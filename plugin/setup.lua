require 'tsmotions'

-- <Plugin> mappings for tsmotions
vim.keymap.set('n', '<Plug>(MoveToNextId)', function() require('tsmotions').NextId() end, { noremap = true })
vim.keymap.set('n', '<Plug>(MoveToPrevId)', function() require('tsmotions').PrevId() end, { noremap = true })
