return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'AndreM222/copilot-lualine',
  },
  config = function()
    local lazy_status = require("lazy.status")
    local devicons = require("nvim-web-devicons")

    -- LSP status component: icon + active LSP names
    local lsp_active = function()
      local lsps = vim.lsp.get_clients({ bufnr = 0 })
      local icon = devicons.get_icon_by_filetype(vim.bo.filetype) or ""

      if lsps and #lsps > 0 then
        local names = {}
        for _, lsp in ipairs(lsps) do
          table.insert(names, lsp.name)
        end
        return string.format("%s [%s]", icon, table.concat(names, ", "))
      else
        return icon
      end
    end

    -- LSP color based on devicons
    local lsp_color = function()
      local _, color = devicons.get_icon_cterm_color_by_filetype(vim.bo.filetype)
      return { fg = color or nil }
    end

    -- Base lualine options
    local opts = {
      options = {
        theme = "onedark",
        globalstatus = true,        -- One statusline for all windows
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = {
          {
            'mode',
            fmt = function(str) return str:sub(1, 1) end,
          },
        },
        lualine_b = {
          'branch',
          'diff',
          {
            'diagnostics',
            sources = { "nvim_diagnostic" },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
          },
          {
            lsp_active,
            color = lsp_color,
            cond = function()
              return #vim.lsp.get_clients({ bufnr = 0 }) > 0
                     or (devicons.get_icon_by_filetype(vim.bo.filetype) or "") ~= ""
            end,
          },
        },
        lualine_c = {
          'copilot',
          'filename',
        },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          'encoding',
          'fileformat',
          'filetype',
        },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = {},
    }

    require("lualine").setup(opts)
  end
}
