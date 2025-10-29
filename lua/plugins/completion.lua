local source_priority = {
	snippets = 5,
	copilot = 4,
	lsp = 3,
	path = 2,
	buffer = 1,
}

return {
	{
		"L3MON4D3/LuaSnip",
		event = "BufEnter",
		version = "v2.*",
		build = "make install_jsregexp",
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ "nvim-dap-ui" },
			},
		},
	},
	{
		"saghen/blink.cmp",
		event = "BufEnter",
		dependencies = {
			"rafamadriz/friendly-snippets",
			"fang2hou/blink-copilot",
		},
		version = "1.*",
		opts = {
			keymap = {
				preset = "super-tab",
				["<Tab>"] = {
					function(cmp)
						if vim.b[vim.api.nvim_get_current_buf()].nes_state then
							cmp.hide()
							return (
								require("copilot-lsp.nes").apply_pending_nes()
								and require("copilot-lsp.nes").walk_cursor_end_edit()
							)
						end
						if cmp.snippet_active() then
							return cmp.accept()
						else
							return cmp.select_and_accept()
						end
					end,
					"snippet_forward",
					"fallback",
				},
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				ghost_text = {
					enabled = true,
				},
				list = {
					selection = {
						preselect = false,
						auto_insert = true,
					},
				},
				menu = {
					border = "single",
					scrolloff = 1,
					scrollbar = false,
					draw = {
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "source_name" },
						},
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 500,
				},
			},
			sources = {
				default = { "lazydev", "copilot", "lsp", "path", "snippets", "buffer" },
				providers = {
					copilot = {
						name = "copilot",
						module = "blink-copilot",
						score_offset = 100,
						async = true,
					},
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
					cmdline = {
						min_keyword_length = 2,
					},
				},
			},
			cmdline = {
				completion = { menu = { auto_show = true } },
				keymap = {
					preset = "inherit",
				},
			},
			snippets = { preset = "luasnip" },
			fuzzy = {
				implementation = "prefer_rust_with_warning",
				sorts = {
					function(a, b)
						local a_priority = source_priority[a.source_id]
						local b_priority = source_priority[b.source_id]
						if a_priority ~= b_priority then
							return a_priority > b_priority
						end
					end,
					"score",
					"sort_text",
				},
			},
		},
		opts_extend = { "sources.default" },
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			filetypes = {
				go = true,
				-- help = true,
				html = true,
				javascript = true,
				lua = true,
				markdown = true,
				python = true,
				sh = true,
				yaml = true,
				["*"] = false,
			},
			suggestion = { enabled = false },
			panel = { enabled = false },
			nes = { enabled = true }, -- (optional) for NES functionality
		},
	},
	{
		"copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
		init = function()
			vim.g.copilot_nes_debounce = 500
			vim.lsp.enable("copilot_ls")
			vim.keymap.set("n", "<tab>", function()
				local bufnr = vim.api.nvim_get_current_buf()
				local state = vim.b[bufnr].nes_state
				if state then
					-- Try to jump to the start of the suggestion edit.
					-- If already at the start, then apply the pending suggestion and jump to the end of the edit.
					local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
						or (
							require("copilot-lsp.nes").apply_pending_nes()
							and require("copilot-lsp.nes").walk_cursor_end_edit()
						)
					return nil
				else
					-- Resolving the terminal's inability to distinguish between `TAB` and `<C-i>` in normal mode
					return "<C-i>"
				end
			end, { desc = "Accept Copilot NES suggestion", expr = true })
		end,
		config = function()
			-- Clear copilot suggestion with Esc if visible, otherwise clear search highlights
			vim.keymap.set("n", "<esc>", function()
				if require("copilot-lsp.nes").clear() then
					return -- Copilot suggestion cleared, done
				end
				-- No Copilot suggestion, fall back to clearing search highlights
				vim.cmd("nohlsearch")
			end, { desc = "Clear Copilot suggestion or search highlights" })
		end,
	},
}
