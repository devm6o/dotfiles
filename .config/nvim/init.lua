vim.cmd([[
set runtimepath^=~/.vim runtimepath+=~/.vim/after
source ~/.vimrc
]])

require("keymaps")
require("lsp")
