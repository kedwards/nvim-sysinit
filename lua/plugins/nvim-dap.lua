return {
	"mfussenegger/nvim-dap",
	event = "VeryLazy",
	dependencies = {
		{
			"igorlfs/nvim-dap-view",
			opts = {
				winbar = {
					default_section = "scopes",
					controls = {
						enabled = true,
					},
				},
				windows = { height = 18 },
				switchbuf = "usetab,uselast",
			},
		},
		{
			"jay-babu/mason-nvim-dap.nvim",
			dependencies = "mason-org/mason.nvim",
			cmd = { "DapInstall", "DapUninstall" },
			opts = {
				ensure_installed = {},
				automatic_installation = true,
				handlers = {
					function(config)
						require("mason-nvim-dap").default_setup(config)
					end,
				},
			},
			config = function(_, opts)
				require("mason").setup()
				require("mason-nvim-dap").setup(opts)
			end,
		},
		-- Virtual text.
		{
			"theHamsta/nvim-dap-virtual-text",
			opts = { virt_text_pos = "eol" },
		},
		-- Lua adapter.
		{
			"jbyuki/one-small-step-for-vimkind",
			keys = {
				{
					"<leader>dl",
					function()
						require("osv").launch({ port = 8086 })
					end,
					desc = "Launch Lua adapter",
				},
			},
		},
	},
	keys = {
		{
			"<leader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Breakpoint Condition",
		},
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle Breakpoint",
		},
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "Run/Continue",
		},
		{
			"<leader>dC",
			function()
				require("dap").run_to_cursor()
			end,
			desc = "Run to Cursor",
		},
		{
			"<leader>dg",
			function()
				require("dap").goto_()
			end,
			desc = "Go to Line (No Execute)",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "Step Into",
		},
		{
			"<leader>dj",
			function()
				require("dap").down()
			end,
			desc = "Down",
		},
		{
			"<leader>dk",
			function()
				require("dap").up()
			end,
			desc = "Up",
		},
		{
			"<leader>dl",
			function()
				require("dap").run_last()
			end,
			desc = "Run Last",
		},
		{
			"<leader>do",
			function()
				require("dap").step_out()
			end,
			desc = "Step Out",
		},
		{
			"<leader>dO",
			function()
				require("dap").step_over()
			end,
			desc = "Step Over",
		},
		{
			"<leader>dP",
			function()
				require("dap").pause()
			end,
			desc = "Pause",
		},
		{
			"<leader>dr",
			function()
				require("dap").repl.toggle()
			end,
			desc = "Toggle REPL",
		},
		{
			"<leader>ds",
			function()
				require("dap").session()
			end,
			desc = "Session",
		},
		{
			"<leader>dt",
			function()
				require("dap").terminate()
			end,
			desc = "Terminate",
		},
		{
			"<leader>dq",
			function()
				require("dap").terminate()
				require("dap-view").close()
				require("nvim-dap-virtual-text").toggle()
			end,
			desc = "Terminate",
		},
	},
	config = function()
		local dap = require("dap")
		local dapview = require("dap-view")

		-- Highlight line debugger is stopped on
		vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

		-- Set up icons.
		local icons = {
			Stopped = { "", "DiagnosticWarn", "DapStoppedLine" },
			Breakpoint = "",
			BreakpointCondition = "",
			BreakpointRejected = { "", "DiagnosticError" },
			LogPoint = "",
		}

		for name, sign in pairs(icons) do
			sign = type(sign) == "table" and sign or { sign }
			vim.fn.sign_define("Dap" .. name, {
        -- stylua: ignore
        text = sign[1] --[[@as string]] .. ' ',
				texthl = sign[2] or "DiagnosticInfo",
				linehl = sign[3],
				numhl = sign[3],
			})
		end

		-- Automatically open the UI when a new debug session is created.
		dap.listeners.before.attach.dapview = function()
			dapview.open()
		end
		dap.listeners.before.launch.dapview = function()
			dapview.open()
		end
		dap.listeners.after.event_initialized.dapview = function()
			dapview.open()
		end
		dap.listeners.before.event_terminated.dapview = function()
			dapview.close()
		end
		dap.listeners.before.event_exited.dapview = function()
			dapview.close()
		end

		require("which-key").add({
			{ "<leader>d", group = "Debugger" },
		})
	end,
}
