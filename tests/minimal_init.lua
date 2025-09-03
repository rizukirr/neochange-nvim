-- Minimal init for testing
local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
vim.opt.rtp:prepend(plugin_dir)
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/plenary.nvim")
package.path = package.path .. ";" .. plugin_dir .. "/lua/?.lua;" .. plugin_dir .. "/lua/?/init.lua"

-- Only load plenary for testing
require("plenary.busted")
