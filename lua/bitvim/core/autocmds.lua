-- core/autocmds.lua

local autocmd = vim.api.nvim_create_autocmd
local augroup = function(name)
  return vim.api.nvim_create_augroup("bit_" .. name, { clear = true })
end

-- Highlight yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Restore cursor
autocmd("BufReadPost", {
  group = augroup("restore_cursor"),
  callback = function(ev)
    local skip = { gitcommit = true, gitrebase = true }
    local ft = vim.bo[ev.buf].filetype
    if skip[ft] then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lines = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close misc filetypes with q
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "lspinfo", "qf", "query", "checkhealth", "man" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- Resize splits
autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. tab)
  end,
})

-- Check external changes
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Cursorline only on active window
autocmd({ "InsertEnter", "WinLeave", "InsertLeave", "WinEnter" }, {
  group = augroup("cursorline_toggle"),
  callback = function(ev)
    local show = (ev.event == "InsertLeave" or ev.event == "WinEnter")
    if show and vim.bo[ev.buf].buftype == "" then
      vim.wo.cursorline = true
    else
      vim.wo.cursorline = false
    end
  end,
})
