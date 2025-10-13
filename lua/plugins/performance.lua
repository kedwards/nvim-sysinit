return {
  -- Startup time profiler
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    keys = {
      { "<leader>pst", "<cmd>StartupTime<cr>", desc = "Startup Time Profile" },
    },
  },
  
  -- Plugin performance analyzer
  {
    "folke/lazy.nvim",
    opts = function(_, opts)
      -- Add performance monitoring
      opts.performance = vim.tbl_extend("force", opts.performance or {}, {
        cache = {
          enabled = true,
        },
        reset_packpath = true,
        rtp = vim.tbl_extend("force", opts.performance and opts.performance.rtp or {}, {
          reset = true,
          paths = {},
          disabled_plugins = vim.tbl_extend("force", 
            opts.performance and opts.performance.rtp and opts.performance.rtp.disabled_plugins or {},
            {
              "gzip",
              "netrwPlugin",
              "tarPlugin", 
              "tohtml",
              "tutor",
              "zipPlugin",
            }
          ),
        }),
      })
      return opts
    end,
  },
}