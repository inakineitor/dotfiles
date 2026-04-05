return {
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },
  -- not vim.g.neovide and {
  --   "3rd/image.nvim",
  --   build = false,
  --   version = "1.4.0",
  --   opts = {
  --     processor = "magick_cli",
  --     backend = "kitty",
  --     integrations = {},
  --     max_width = 100,
  --     max_height = 12,
  --     max_height_window_percentage = math.huge,
  --     max_width_window_percentage = math.huge,
  --     window_overlap_clear_enabled = true,
  --     window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
  --   },
  -- } or nil,
}
