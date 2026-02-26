return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has "nvim-0.10.0" == 1,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "rust_analyzer",
        "bash-language-server",
        "gopls",
        "docker-language-server",
        "css-lsp",
        "gradle-language-server",
        "hyprls",
        "jedi-language-server",
        "html-lsp",
        "jq-lsp",
        "yaml-language-server",
      },
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup {
        opts = {
          -- Defaults
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = false, -- Auto close on trailing </
        },
        -- Also override individual filetype configs, these take priority.
        -- Empty by default, useful if one of the "opts" global settings
        -- doesn't work well in a specific filetype
        per_filetype = {
          ["html"] = {
            enable_close = true,
          },
        },
      }
    end,
  },

  {
    "OXY2DEV/markview.nvim",
    lazy = false,

    -- Completion for `blink.cmp`
    -- dependencies = { "saghen/blink.cmp" },
  },

  {
    "elmcgill/springboot-nvim",
    dependencies = {
      "mfussenegger/nvim-jdtls",
    },
    config = function()
      local springboot_nvim = require "springboot-nvim"
      springboot_nvim.setup {
        on_compile_result = nil,
      }
    end,
  },
  { import = "nvchad.blink.lazyspec" },
  {
    "nvim-mini/mini.ai",
    version = false,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "rust",
        "python",
        "go",
        "java",
        "markdown",
        "json",
        "tsx",
        "yaml",
        "bash",
      },
    },
  },
}
