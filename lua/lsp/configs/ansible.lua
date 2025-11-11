-- Ansible Language Configuration
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#ansiblels
-- npm install -g @ansible/ansible-language-server

return {
	-- LSP
	lsp = {
		ansiblels = {
			name = "ansible-language-server",
			settings = {},
		},
	},

	-- Formatters
	format = {
		ansible = { "prettier" },
	},

	-- Linters
	lint = {
		ansible = { "ansible-lint" },
	},

	-- DAP
	dap = {},
}
