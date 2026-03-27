return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 20,
      open_mapping = "<leader>fq",
      direction = "horizontal",
      insert_mappings = false,
    },
  },
  {
    "nvzone/floaterm",
    dependencies = "nvzone/volt",
    opts = {
      mappings = {
        sidebar = function(buf)
          vim.keymap.set("n", "<leader>ft", "<cmd>FloatermToggle<cr>", { buffer = buf })
        end,
        term = function(buf)
          vim.keymap.set({ "n", "t" }, "<leader>ft", "<cmd>FloatermToggle<cr>", { buffer = buf })
        end,
      },
      -- Default sets of terminals you'd like to open
      terminals = {
        { name = "Terminal" },
        -- { name = "Terminal", cmd = "neofetch" },
      },
    },
    cmd = "FloatermToggle",
  },
}
