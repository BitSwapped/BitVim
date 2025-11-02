--- core/options.lua ---

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opts = {
	-- Files & Backup
	backup = false,
	writebackup = false,
	swapfile = false,
	undofile = true,
	undodir = vim.fn.stdpath("data") .. "/undo",
	undolevels = 10000,

	-- Behavior
	hidden = true,
	confirm = true,
	autowrite = false,

	-- Clipboard
	clipboard = "unnamed",

	-- Encoding
	encoding = "utf-8",
	fileencoding = "utf-8",

	-- Folding
	foldmethod = "expr",
	foldexpr = "v:lua.vim.treesitter.foldexpr()",
	foldenable = true,
	foldlevel = 99,
	foldlevelstart = 99,
	foldtext = "",

	-- Indentation
	autoindent = true,
	smartindent = true,
	copyindent = true,
	preserveindent = true,
	expandtab = true,
	shiftwidth = 2,
	tabstop = 2,
	softtabstop = 2,
	shiftround = true,

	-- Line Numbers
	number = true,
	relativenumber = true,

	-- Performance
	lazyredraw = false,
	timeoutlen = 350,

	-- Scrolling
	scrolloff = 8,
	sidescrolloff = 8,
	smoothscroll = true,

	-- Searching
	ignorecase = true,
	smartcase = true,
	infercase = true,
	hlsearch = true,
	incsearch = true,
	inccommand = "nosplit",

	-- Grep
	grepprg = "rg --vimgrep",
	grepformat = "%f:%l:%c:%m",

	-- UI/Appearance
	termguicolors = true,
	background = "dark",
	cursorline = true,
	signcolumn = "yes",
	--cmdheight = 0,
	pumheight = 10,
	pumblend = 10,
	showmode = false,
	laststatus = 3,
	showtabline = 2,

	-- Visual & Formatting
	breakindent = true,
	linebreak = true,
	wrap = false,
	virtualedit = "block",
	list = false,

	-- Fill characters
	fillchars = {
		foldopen = "",
		foldclose = "",
		fold = " ",
		foldsep = " ",
		diff = "╱",
		eob = " ",
	},

	-- Format options
	formatoptions = "jcroqlnt",

	-- Completion
	completeopt = { "menu", "menuone", "noselect" },

	-- Shortmess
	shortmess = "aoOTIcFWs",

	-- Session
	sessionoptions = {
		"buffers",
		"curdir",
		"tabpages",
		"winsize",
		"help",
		"globals",
		"skiprtp",
		"folds",
	},

	-- Windows/Splits
	splitbelow = true,
	splitright = true,
	splitkeep = "screen",

	-- Wildmenu
	wildmode = "longest:full,full",
	wildoptions = "pum",

	-- Backspace behavior
	backspace = { "nostop", "indent", "eol", "start" },

	-- Jumps
	jumpoptions = "view",

	-- Mouse & Misc
	mouse = "a",
	title = true,
	ruler = false,
}

-- Apply options
for k, v in pairs(opts) do
	vim.opt[k] = v
end
