local M = {}

--- Get enhanced LSP capabilities with completion engine support
--- @return lsp.ClientCapabilities
function M.get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Enhanced text document capabilities
  capabilities.textDocument = vim.tbl_deep_extend("force", capabilities.textDocument, {
    completion = {
      dynamicRegistration = false,
      completionItem = {
        snippetSupport = true,
        commitCharactersSupport = true,
        documentationFormat = { "markdown", "plaintext" },
        deprecatedSupport = true,
        preselectSupport = true,
        tagSupport = { valueSet = { 1 } },
        insertReplaceSupport = true,
        resolveSupport = {
          properties = { "documentation", "detail", "additionalTextEdits" },
        },
        insertTextModeSupport = { valueSet = { 1, 2 } },
      },
    },
    semanticTokens = {
      multilineTokenSupport = true,
      overlappingTokenSupport = true,
      tokenTypes = {
        "namespace", "type", "class", "enum", "interface", "struct", "typeParameter",
        "parameter", "variable", "property", "enumMember", "event", "function",
        "method", "macro", "keyword", "modifier", "comment", "string", "number",
        "regexp", "operator", "decorator"
      },
      tokenModifiers = {
        "declaration", "definition", "readonly", "static", "deprecated", "abstract",
        "async", "modification", "documentation", "defaultLibrary"
      },
    },
    codeAction = {
      dynamicRegistration = true,
      isPreferredSupport = true,
      disabledSupport = true,
      dataSupport = true,
      resolveSupport = {
        properties = { "edit" },
      },
      codeActionLiteralSupport = {
        codeActionKind = {
          valueSet = {
            "",
            "quickfix",
            "refactor",
            "refactor.extract",
            "refactor.inline",
            "refactor.rewrite",
            "source",
            "source.organizeImports",
          },
        },
      },
    },
    hover = {
      dynamicRegistration = true,
      contentFormat = { "markdown", "plaintext" },
    },
    signatureHelp = {
      dynamicRegistration = true,
      signatureInformation = {
        documentationFormat = { "markdown", "plaintext" },
        parameterInformation = {
          labelOffsetSupport = true,
        },
      },
    },
    definition = {
      dynamicRegistration = true,
      linkSupport = true,
    },
    references = {
      dynamicRegistration = true,
    },
    documentHighlight = {
      dynamicRegistration = true,
    },
    documentSymbol = {
      dynamicRegistration = true,
      symbolKind = {
        valueSet = {
          1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26
        },
      },
      hierarchicalDocumentSymbolSupport = true,
    },
    formatting = {
      dynamicRegistration = true,
    },
    rangeFormatting = {
      dynamicRegistration = true,
    },
    rename = {
      dynamicRegistration = true,
      prepareSupport = true,
    },
    inlayHint = {
      dynamicRegistration = true,
      resolveSupport = {
        properties = { "tooltip", "textEdits", "label.tooltip", "label.command" },
      },
    },
  })

  -- Integrate with completion engine (blink.cmp)
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink.get_lsp_capabilities then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  return capabilities
end

--- Get capabilities for a specific server with overrides
--- @param overrides? lsp.ClientCapabilities
--- @return lsp.ClientCapabilities
function M.get_server_capabilities(overrides)
  local base_capabilities = M.get_capabilities()

  if not overrides then
    return base_capabilities
  end

  return vim.tbl_deep_extend("force", base_capabilities, overrides)
end

return M
