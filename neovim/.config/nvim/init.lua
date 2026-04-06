-- Set <space> as leader (must happen before other plugins loaded)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Relative line numbers
vim.o.relativenumber = true
vim.o.number = true -- display absolute line number instead of 0

-- Don't show mode (INSERT-NORMAL-...) in status line
vim.o.showmode = false

-- Sync vim and system clipboards
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Raise dialog if you close unsaved buffer (prevent mistakes)
vim.o.confirm = true

-- Snappy escape
vim.o.ttimeoutlen = 1

-- Vim diagnostics
vim.diagnostic.config({
  severity_sort = true, -- show most severe error first
  update_in_insert = false, -- don't update while typing
  float = { source = 'if_many' }, -- nicer look for floats and show source if multiple sources (ex. ruff and ty)
  jump = { float = true }, -- automatically open the diagnostic float if you jump with [d ]d
})

-- Show diagnostics
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, {desc = 'Show diagnostics'})

-- Easily move between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight yanks 
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', {clear = true}),
  callback = function() vim.highlight.on_yank() end,
})

-- Plugins
-- Pack guide: https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack#update
vim.pack.add({
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/nvim-treesitter/nvim-treesitter', -- also $ brew install tree-sitter-cli
  'https://github.com/neovim/nvim-lspconfig',
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.x')} -- pinning so rust binary dependency automatically downloads
})

-- FzfLua Setup
require('fzf-lua').setup({
 keymap = {
   builtin = {
      ["<C-d>"]  = 'preview-page-down', -- Better scrolling within the displays
      ["<C-u>"]  = 'preview-page-up',
   },
 },
})

vim.keymap.set('n', '<leader><leader>', '<cmd>FzfLua files<cr>', { desc = 'Find files'})
vim.keymap.set('n', '<leader>/', '<cmd>FzfLua live_grep<cr>', { desc = 'Find live grep'})

-- Treesitter
vim.cmd('syntax off') -- Make it obvious if treesitter is missing
vim.api.nvim_create_autocmd('FileType', {
 callback = function() pcall(vim.treesitter.start) end,
})

-- LSP
vim.lsp.enable({
  'ty', -- also $ uv tool install ty@latest
  'ruff', -- also $ uv tool install ruff@latest
  'lua_ls' -- also $ brew install lua-language-server
})
vim.o.signcolumn = 'yes' -- make lsp warnings not widen the gutter

-- Blink.cmp
require('blink.cmp').setup({})
