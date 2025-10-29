-- Setup global LSP configuration
require("lsp.config").setup()

-- Setup diagnostics
require("lsp.diagnostics").init()

-- Setup management commands
require("lsp.commands").setup()

-- lsp loader
require("lsp.loader").setup()
