-- NeoChange plugin entry point
if vim.g.loaded_neochange then
  return
end
vim.g.loaded_neochange = 1

-- Setup commands when plugin loads
require('neochange.commands').setup()