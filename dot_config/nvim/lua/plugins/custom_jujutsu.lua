return {
  {
    "mrdwarf7/lazyjui.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        -- Default is <Leader>jj
        -- An example of a custom mapping to open the interface
        "<Leader>gj",
        function()
          require("lazyjui").open()
        end,
      },
    },
  },
}
