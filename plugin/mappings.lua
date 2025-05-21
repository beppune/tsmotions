require 'tsmotions'

-- <Plugin> mappings for tsmotions
vim.keymap.set('n', '<Plug>(MoveToNextId)', ':lua package.loaded.tsmotions.NextId()<Enter>', { noremap = true }   )
vim.keymap.set('n', '<Plug>(MoveToPrevId)', ':lua package.loaded.tsmotions.PrevId()<Enter>', { noremap = true }   )
