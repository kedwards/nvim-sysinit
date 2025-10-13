-- Python Language Configuration
-- LSP, formatting, and linting setup for Python files

return {
  -- LSP servers for Python
  lsp = {
    pyright = {
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "basic",
            autoSearchPaths = true,
            diagnosticMode = "workspace",
            useLibraryCodeForTypes = true,
            autoImportCompletions = true,
          },
        },
      },
    },
    -- Alternative: pylsp
    -- pylsp = {
    --   settings = {
    --     pylsp = {
    --       plugins = {
    --         pycodestyle = { enabled = false },
    --         mccabe = { enabled = false },
    --         pyflakes = { enabled = false },
    --         flake8 = { enabled = true },
    --         mypy = { enabled = true },
    --         isort = { enabled = true },
    --         black = { enabled = true },
    --       },
    --     },
    --   },
    -- },
  },

  -- Formatters for Python
  format = {
    python = { "ruff", "isort" },
  },

  -- Linters for Python
  lint = {
    python = { "ruff", "mypy" },
  },

  -- DAP configuration for Python debugging
  dap = {
    python = {
      type = "python",
      request = "launch",
      program = "${file}",
      console = "integratedTerminal",
    },
  },
}