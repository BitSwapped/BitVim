--- utils/keymap.lua ---

---@class Utils.Keymap
local M = {}

---@class KeymapOpts
---@field desc? string Description for which-key
---@field silent? boolean Don't echo command
---@field noremap? boolean Don't allow remapping
---@field buffer? number Buffer-local keymap
---@field expr? boolean Expression mapping
---@field nowait? boolean Don't wait for more keys
---@field remap? boolean Allow remapping (overrides noremap)

---Set keymap with better defaults
---@param mode string|string[] Mode(s): 'n', 'v', 'i', etc.
---@param lhs string Left-hand side (key to press)
---@param rhs string|function Right-hand side (command or function)
---@param opts? KeymapOpts Options table
function M.map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", {
    noremap = true,
    silent = true,
  }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

return M
