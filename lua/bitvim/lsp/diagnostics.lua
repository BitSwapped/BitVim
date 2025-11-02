--- lsp/diagnostics.lua ---

local M = {}

function M.setup()
	M.signs = {
		Error = " ",
		Warn = " ",
		Hint = "󰌶 ",
		Info = " ",
	}

	for type, icon in pairs(M.signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	end

	vim.diagnostic.config({
		virtual_text = {
			spacing = 4,
			source = "if_many",
			prefix = "●",
			format = function(diagnostic)
				local severity_icons = {
					[vim.diagnostic.severity.ERROR] = M.signs.Error,
					[vim.diagnostic.severity.WARN] = M.signs.Warn,
					[vim.diagnostic.severity.HINT] = M.signs.Hint,
					[vim.diagnostic.severity.INFO] = M.signs.Info,
				}
				return string.format("%s %s", severity_icons[diagnostic.severity] or "", diagnostic.message)
			end,
		},
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = M.signs.Error,
				[vim.diagnostic.severity.WARN] = M.signs.Warn,
				[vim.diagnostic.severity.HINT] = M.signs.Hint,
				[vim.diagnostic.severity.INFO] = M.signs.Info,
			},
		},
		update_in_insert = false,
		underline = { severity = { min = vim.diagnostic.severity.HINT } },
		severity_sort = true,
		float = {
			focusable = false,
			style = "minimal",
			border = "rounded",
			source = "if_many",
			header = "",
			prefix = "",
			format = function(diagnostic)
				local code = diagnostic.code
					or diagnostic.user_data and diagnostic.user_data.lsp and diagnostic.user_data.lsp.code
				return code and string.format("%s [%s]", diagnostic.message, code) or diagnostic.message
			end,
		},
	})
end

return M
