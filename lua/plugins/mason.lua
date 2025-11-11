return {
	"mason-org/mason.nvim",
	cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
	keys = {
		{ "<leader>pm", "<cmd>Mason<cr>", desc = "Mason" },
	},
	build = ":MasonUpdate",
	opts = {
		ui = {
			border = "rounded",
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
	},
}
