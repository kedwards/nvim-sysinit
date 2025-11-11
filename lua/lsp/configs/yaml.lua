-- Yaml Language Configuration
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#yamlls
-- npm install -g yaml-language-server

return {
	-- LSP
	lsp = {
		yamlls = {
			name = "yaml-language-server",
			settings = {
				yaml = {
					schemaStore = {
						enable = false,
						url = "",
					},
					schemas = require("schemastore").yaml.schemas(),
				},
				-- yamlls = {
				-- 	schemas = {
				-- 		["http://json.schemastore.org/ansible-2.9"] = "playbook.yml",
				-- 	},
				-- },
			},
		},
	},

	-- Formatters
	format = {
		yaml = { "prettier" },
	},

	-- Linters
	lint = {
		yaml = { "yamllint" },
	},

	-- DAP
	dap = {},
}
