--- lsp/servers.lua ---

local servers = {
	-- Lua Language Server
	lua_ls = {
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
				},
				workspace = {
					checkThirdParty = false,
					library = {
						vim.env.VIMRUNTIME,
						"${3rd}/luv/library",
					},
				},
				completion = {
					callSnippet = "Replace",
				},
				diagnostics = {
					globals = { "vim" },
					disable = { "missing-fields" },
				},
				hint = {
					enable = false,
					setType = true,
				},
				format = {
					enable = true,
					defaultConfig = {
						indent_style = "space",
						indent_size = "2",
					},
				},
				telemetry = {
					enable = false,
				},
			},
		},
	},

	-- C/C++ Language Server (clangd)
	clangd = {
		root_markers = {
			"compile_commands.json",
			"compile_flags.txt",
			".clangd",
			".clang-format",
			"CMakeLists.txt",
		},

		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
			"--header-insertion=iwyu",
			"--completion-style=detailed",
			"--function-arg-placeholders",
			"--fallback-style=llvm",
		},

		-- Override capabilities to specify offset encoding
		capabilities = (function()
			local caps = vim.lsp.protocol.make_client_capabilities()
			caps.offsetEncoding = { "utf-16" }
			return caps
		end)(),

		-- Init options
		init_options = {
			usePlaceholders = true,
			completeUnimported = true,
			clangdFileStatus = true,
		},
	},
}

return servers
