return {
  {
    "vimpostor/vim-lumen",
    version = "*",
    lazy = false,
  },
  {
    "navarasu/onedark.nvim",
    opts = {
      style = "darker",
      colors = {
        bg0 = "#000000", -- Background color
        bg1 = "#191919", -- Line highlight color
        -- bg3 = "#000000", -- Visual mode selection
        -- bg4 = "#000000", -- Card color and status line color
        bg_d = "#000000",
      },
    },
  },
  {
    "yorik1984/newpaper.nvim",
    priority = 1000,
    opts = function(opts)
      local colors = {
        bg = "#e4e5f5",
        silver = "#E4E4E4",
        lightsilver = "#EEEEEE",
      }

      return {
        disable_background = true,
        preset = {},
        colors = colors,
        colors_advanced = {
          active = colors.silver,
          cursor_nr_bg = colors.silver,
          linenumber_bg = colors.bg,

          term_contrast_fl_bg = colors.silver,
          normal_bg = colors.bg,
          winbar_bg = "#00ffff",

          sb_contrast_bg = "#00ff00",
          sb_bg = "#ffff00",
          telescope_bg = "#ff0000",
          float_bg = colors.bg,
          float_contrast = "#0000ff",
          telescope_contrast = "#ffff00",
          term_contrast_bg = "#00ffff",
          colorcol = colors.lightsilver,
          tabline_inactive_bg = "#ffff00",
        },
      }
    end,
  },
  {
    "vimpostor/vim-prism",
    config = function()
      -- Blank to address startup error
    end,
  },
  {
    "dundargoc/fakedonalds.nvim",
  },
  {
    "LazyVim/LazyVim",
    dependencies = { "vimpostor/vim-lumen" }, -- Ensure that the background property is correctly set before loading theme
    opts = function()
      local theme_kind = vim.o.background

      if theme_kind == "light" then
        return {
          colorscheme = "newpaper",
        }
      end

      return {
        colorscheme = "onedark", -- options: ["onedark", "newpaper", "prism"]
      }
    end,
  },
}
