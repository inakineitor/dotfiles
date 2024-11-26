-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

if vim.g.neovide then
  vim.o.guifont = "Menlo,Monaco,Courier New:h14"
  vim.opt.linespace = 0
  vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_scroll_animation_far_lines = 1
  vim.g.neovide_refresh_rate = 90
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_trail_size = 0.8
  vim.g.neovide_cursor_animate_command_line = false
end

-- Set the local leader
vim.g.maplocalleader = ","

-- Set better characters for spaces
local space = "·"
vim.opt.listchars:append {
    -- tab = "ak",
    -- multispace = "b",
    -- lead = "c",
    trail = space,
    -- nbsp = "e",
}


-- Scrolling options
vim.opt.scrolloff = 20

-- Tab indentation options
vim.o.expandtab = true -- expand tab input with spaces characters
vim.o.smartindent = true -- syntax aware indentations for newline inserts
vim.o.tabstop = 2 -- num of space characters per tab
vim.o.shiftwidth = 2 -- spaces per indentation level