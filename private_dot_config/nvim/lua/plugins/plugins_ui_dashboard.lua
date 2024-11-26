return {
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function()
      local logo = [[
    .....     .    ,68b.   ,                     ..         .    
  .d88888Neu. 'L   '   `Y89'               < .z@8"`        @88>  
  F""""*8888888F    u.    u.                !@88E          %8P   
 *      `"*88*"   x@88k u@88c.       u      '888E   u       .    
  -....    ue=:. ^"8888""8888"    us888u.    888E u@8NL   .@88u  
         :88N  `   8888  888R  .@88 "8888"   888E`"88*"  ''888E` 
         9888L     8888  888R  9888  9888    888E .dN.     888E  
  uzu.   `8888L    8888  888R  9888  9888    888E~8888     888E  
,""888i   ?8888    8888  888R  9888  9888    888E '888&    888E  
4  9888L   %888>  "*88*" 8888" 9888  9888    888E  9888.   888&  
'  '8888   '88%     ""   'Y"   "888*""888" '"888*" 4888"   R888" 
     "*8Nu.z*"                  ^Y"   ^Y'     ""    ""      ""   
      ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"

      local opts = {
        theme = "doom",
        hide = {
          -- this is taken care of by lualine
          -- enabling this messes up the actual laststatus setting after loading a file
          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
          -- stylua: ignore
          center = {
            { action = LazyVim.pick("files"),                                      desc = " Find File",       icon = " ", key = "f" },
            { action = "ene | startinsert",                                        desc = " New File",        icon = " ", key = "n" },
            { action = "Telescope oldfiles",                                       desc = " Recent Files",    icon = " ", key = "r" },
            { action = "Telescope live_grep",                                      desc = " Find Text",       icon = " ", key = "g" },
            { action = [[lua LazyVim.pick.config_files()()]],                      desc = " Config",          icon = " ", key = "c" },
            { action = 'lua require("persistence").load()',                        desc = " Restore Session", icon = " ", key = "s" },
            { action = "LazyExtras",                                               desc = " Lazy Extras",     icon = " ", key = "x" },
            { action = "Lazy",                                                     desc = " Lazy",            icon = "󰒲 ", key = "l" },
            { action = "qa",                                                       desc = " Quit",            icon = " ", key = "q" },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "DashboardLoaded",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      return opts
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "LazyFile",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
    main = "ibl",
  },
  {
    "echasnovski/mini.indentscope",
    opts = {
      symbol = "│",
      draw = { animation = require("mini.indentscope").gen_animation.none() }, -- Disable the animation
      options = { try_as_border = true },
    },
  },
}
