local capabilities = require("lsp.capabilities")

local M = {}

--- Configure global LSP defaults
function M.setup()
	vim.lsp.config("*", {
		capabilities = capabilities.get_capabilities(),
		root_markers = { ".git", ".hg", ".svn" },

		-- Global settings that apply to all servers
		settings = {},

		-- Default handlers
		handlers = {
			["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
				focusable = false,
			}),
			["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "rounded",
				focusable = false,
			}),
		},
	})
end

return M