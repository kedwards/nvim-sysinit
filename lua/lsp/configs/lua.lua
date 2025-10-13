-- Lua Language Configuration
-- LSP, formatting, and linting setup for Lua files

return {
  -- LSP servers for Lua
  lsp = {
    lua_ls = {
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            path = vim.list_extend(vim.split(package.path, ";"), {
              "lua/?.lua",
              "lua/?/init.lua",
            }),
          },
          diagnostics = {
            globals = {
              "vim",                 -- Neovim global
              "describe", "it",      -- Busted testing globals
              "before_each", "after_each",
              "setup", "teardown",
              "pending", "finally",
            },
            disable = {
              "missing-fields",      -- Too noisy for Neovim config
            },
            groupSeverity = {
              strong = "Warning",
              strict = "Warning",
            },
            groupFileStatus = {
              strong = "Opened",
              strict = "Opened",
              fallback = "Opened",
            },
          },
          workspace = {
            library = {
              vim.env.VIMRUNTIME,
              "${3rd}/luv/library",
              "${3rd}/busted/library",
              "${3rd}/luassert/library",
            },
            maxPreload = 100000,
            preloadFileSize = 10000,
            checkThirdParty = false,
          },
          completion = {
            callSnippet = "Replace",
            keywordSnippet = "Replace",
            displayContext = 5,
            workspaceWord = true,
            showWord = "Fallback",
          },
          semantic = {
            enable = true,
            variable = true,
            annotation = true,
            keyword = false, -- Let treesitter handle keywords
          },
          codelens = {
            enable = true,
          },
          hover = {
            enable = true,
            viewNumber = true,
            viewString = true,
            viewStringMax = 1000,
          },
          signatureHelp = {
            enable = true,
          },
          format = {
            enable = false, -- Use stylua instead
          },
          telemetry = {
            enable = false,
          },
          window = {
            progressBar = true,
            statusBar = true,
          },
          misc = {
            parameters = {
              "---@param ${1:param} ${2:type} ${3:description}",
            },
          },
          type = {
            castNumberToInteger = true,
            weakUnionCheck = true,
            weakNilCheck = true,
          },
          IntelliSense = {
            traceBeSetted = false,
            traceFieldInject = false,
            traceLocalSet = false,
            traceReturn = false,
          },
        },
      },
      
      -- Custom initialization for Neovim development
      on_init = function(client)
        -- Safely get the workspace path
        local path
        if client.workspace_folders and #client.workspace_folders > 0 then
          path = client.workspace_folders[1].name
        else
          path = vim.fn.getcwd()
        end

        -- Ensure we have a valid path
        if not path or path == "" then
          return
        end

        -- Check if we're in a Neovim config directory
        local uv = vim.uv or vim.loop
        if uv.fs_stat(path .. '/.luarc.json') or uv.fs_stat(path .. '/.luarc.jsonc') then
          return
        end

        -- Configure for Neovim development
        if path:match("nvim") or path:match("neovim") or path:match("%.config/nvim") then
          -- Ensure client.config and client.config.settings exist
          if not client.config then
            client.config = {}
          end
          if not client.config.settings then
            client.config.settings = {}
          end
          if not client.config.settings.Lua then
            client.config.settings.Lua = {}
          end
          
          client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
              version = "LuaJIT"
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                "${3rd}/luv/library"
              }
            }
          })
          
          -- Safely notify about configuration changes
          local ok, err = pcall(function()
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
          end)
          
          if not ok then
            vim.notify("Failed to update lua_ls workspace configuration: " .. tostring(err), vim.log.levels.WARN)
          end
        end
      end,
    },
  },

  -- Formatters for Lua
  format = {
    lua = { "stylua" },
  },

  -- Linters for Lua  
  lint = {
    lua = { "selene" },
  },

  -- Custom linter configurations
  lint_config = {
    selene = {
      cmd = "selene",
      stdin = false,
      args = { "--config", vim.fn.stdpath("config") .. "/selene.toml" },
      stream = "stdout",
      ignore_exitcode = true,
      parser = require("lint.parser").from_errorformat(
        "%f:%l:%c: %t%*[^:]: %m",
        {
          source = "selene",
          severity = vim.diagnostic.severity.WARN,
        }
      ),
    },
  },

  -- DAP (Debug Adapter Protocol) - optional
  dap = {},
}