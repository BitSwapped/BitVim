--- core/keymaps.lua ---

local map = require("bitvim.utils.keymap").map
local toggle = require("bitvim.utils.toggle")

-- Better Up and Down Movement
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Window Management
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- Centered Searching
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Editor Operations
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Quick Save" })
map("n", "<leader>w", "<cmd>w<cr><esc>", { desc = "Quick Save" })

map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quick Quit Window" })

-- Buffer Operations
map("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New Buffer" })

-- Join lines without changing cursor position
map("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Clear highlights with <Esc>
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })

-- Better Indenting
map("x", "<", "<gv")
map("x", ">", ">gv")
map("x", "<S-Tab>", "<gv")
map("x", "<Tab>", ">gv")

-- Clipboard
map("n", "<leader>y", '"+y<esc>', { desc = "Copy to clipboard" })
map("x", "<leader>y", '"+y<esc>', { desc = "Copy to clipboard" })
map("x", "<leader>dy", '"+y<esc>dd', { desc = "Copy to clipboard and delete line" })
map("n", "<leader>p", '"+p', { desc = "Paste from clipboard" })
map("x", "<leader>p", '"+p', { desc = "Paste from clipboard" })
map("n", "<leader>P", '"+P', { desc = "Paste before from clipboard" })

-- Clipbard [Changing]
map("n", "c", '"_c', { desc = "Change without yanking" })
map("n", "C", '"_C', { desc = "Change without yanking" })
map("x", "c", '"_c', { desc = "Change without yanking" })
map("x", "C", '"_C', { desc = "Change without yanking" })

map("n", "d", '"_d', { desc = "Delete without yanking" })
map("n", "D", '"_D', { desc = "Delete without yanking" })
map("x", "d", '"_d', { desc = "Change without yanking" })
map("x", "D", '"_D', { desc = "Change without yanking" })

-- Delete single character without yanking
map("n", "x", '"_x', { desc = "Delete char without yanking" })
map("n", "X", '"_X', { desc = "Delete char before without yanking" })

-- Better paste in visual mode (don't yank what you're replacing)
map("x", "p", '"_dP', { desc = "Paste without yanking replaced text" })
map("x", "P", '"_dp', { desc = "Paste before without yanking" })

-- Toggles
map("n", "<leader>ud", toggle.diagnostics, { desc = "Toggle Diagnostics" })
map("n", "<leader>un", toggle.number, { desc = "Toggle Line Numbers" })
map("n", "<leader>ur", toggle.relative_number, { desc = "Toggle Relative Numbers" })
map("n", "<leader>uw", toggle.wrap, { desc = "Toggle Line Wrap" })
map("n", "<leader>sh", toggle.hlsearch, { desc = "Toggle Highlight Search" })

-- Diagnostic Display Toggles
map("n", "<leader>uv", toggle.virtual_text, { desc = "Toggle Diagnostic Virtual Text" })
map("n", "<leader>uu", toggle.underline, { desc = "Toggle Diagnostic Underline" })
map("n", "<leader>us", toggle.signs, { desc = "Toggle Diagnostic Signs" })

-- Auto formatting
vim.keymap.set("n", "<leader>uf", toggle.autoformat, { desc = "Toggle Format (Global)" })
vim.keymap.set("n", "<leader>uF", toggle.autoformat_buffer, { desc = "Toggle Format (Buffer)" })
