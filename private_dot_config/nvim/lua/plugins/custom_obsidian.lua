return {
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    event = {
      -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
      "BufReadPre /Users/inakiarango/Documents/Obsidian-Vault/**.md",
      "BufNewFile /Users/inakiarango/Documents/Obsidian-Vault/**.md",
    },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",

      -- Optional
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter",
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "/Users/inakiarango/Documents/Obsidian-Vault",
        },
        -- {
        --   name = "work",
        --   path = "~/vaults/work",
        -- },
      },
      -- ui = {
      --   enable = false,
      -- },
    },
  },
}
