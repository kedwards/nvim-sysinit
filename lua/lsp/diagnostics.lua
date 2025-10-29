local M = {}

--- Configure global diagnostic settings
function M.setup()
  -- Configure diagnostic display
  vim.diagnostic.config({
    -- Enable virtual text with styling
    virtual_text = {
      enabled = true,
      source = "if_many",
      spacing = 4,
      prefix = "●",
      format = function(diagnostic)
        local message = diagnostic.message
        if string.len(message) > 50 then
          message = string.sub(message, 1, 47) .. "..."
        end
        return message
      end,
    },

    -- Show signs in the gutter
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "✘",
        [vim.diagnostic.severity.WARN] = "▲",
        [vim.diagnostic.severity.INFO] = "»",
        [vim.diagnostic.severity.HINT] = "⚑",
      },
      texthl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
      },
      linehl = {},
      numhl = {},
    },

    -- Underline diagnostics
    underline = {
      enabled = true,
      severity = vim.diagnostic.severity.ERROR,
    },

    -- Configure floating windows
    float = {
      enabled = true,
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "if_many",
      header = "",
      prefix = "",
      format = function(diagnostic)
        return string.format("%s (%s)", diagnostic.message, diagnostic.source or "unknown")
      end,
    },

    -- Update diagnostics in insert mode
    update_in_insert = false,

    -- Sort diagnostics by severity
    severity_sort = true,

    -- Jump options
    jump = {
      float = true,
    },
  })

  -- Configure diagnostic highlight groups
  local diagnostic_groups = {
    -- Virtual text colors
    { "DiagnosticVirtualTextError", { fg = "#f38ba8", bg = "NONE", italic = true } },
    { "DiagnosticVirtualTextWarn",  { fg = "#fab387", bg = "NONE", italic = true } },
    { "DiagnosticVirtualTextInfo",  { fg = "#89dceb", bg = "NONE", italic = true } },
    { "DiagnosticVirtualTextHint",  { fg = "#a6e3a1", bg = "NONE", italic = true } },

    -- Underline colors
    { "DiagnosticUnderlineError", { undercurl = true, sp = "#f38ba8" } },
    { "DiagnosticUnderlineWarn",  { undercurl = true, sp = "#fab387" } },
    { "DiagnosticUnderlineInfo",  { undercurl = true, sp = "#89dceb" } },
    { "DiagnosticUnderlineHint",  { undercurl = true, sp = "#a6e3a1" } },

    -- Sign colors
    { "DiagnosticSignError", { fg = "#f38ba8" } },
    { "DiagnosticSignWarn",  { fg = "#fab387" } },
    { "DiagnosticSignInfo",  { fg = "#89dceb" } },
    { "DiagnosticSignHint",  { fg = "#a6e3a1" } },
  }

  for _, group in ipairs(diagnostic_groups) do
    vim.api.nvim_set_hl(0, group[1], group[2])
  end
end

--- Setup diagnostic keymaps
function M.setup_keymaps()
  -- Diagnostic navigation helper
  local function diagnostic_nav(direction, opts)
    opts = opts or { float = true }

    return function()
      vim.diagnostic.jump(vim.tbl_extend("force", opts, {
        count = direction == "next" and 1 or -1,
      }))
    end
  end

  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }

  -- Diagnostic navigation
  map("n", "<leader>dd", vim.diagnostic.open_float, vim.tbl_extend("force", opts, {
    desc = "Show line diagnostics"
  }))

  map("n", "<leader>dq", vim.diagnostic.setqflist, vim.tbl_extend("force", opts, {
    desc = "Send all diagnostics to quickfix"
  }))

  map("n", "<leader>dl", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, {
    desc = "Send buffer diagnostics to location list"
  }))

  -- Diagnostic filtering
  vim.keymap.set("n", "<leader>de", function()
    vim.diagnostic.config({
      virtual_text = { severity = vim.diagnostic.severity.ERROR }
    })
  end, vim.tbl_extend("force", opts, {
  desc = "Show only error diagnostics"
}))

vim.keymap.set("n", "<leader>da", function()
  vim.diagnostic.config({
    virtual_text = { enabled = true }
  })
end, vim.tbl_extend("force", opts, {
desc = "Show all diagnostics"
  }))

  vim.keymap.set("n", "<leader>dt", function()
    local config = vim.diagnostic.config() or {}
    vim.diagnostic.config({
      virtual_text = not config.virtual_text
    })
  end, vim.tbl_extend("force", opts, {
  desc = "Toggle diagnostic virtual text"
}))
end

--- Initialize all diagnostic configurations
function M.init()
  M.setup()
  M.setup_keymaps()
end

return M
