return {
  {
    "mistricky/codesnap.nvim",
    tag = "v2.0.1",
    cmd = { "CodeSnap", "CodeSnapSave", "CodeSnapASCII" },
    opts = {
      snapshot_config = {
        theme = "vercel@https://raw.githubusercontent.com/Railly/one-hunter-vscode/refs/heads/main/themes/OneHunter-Vercel-color-theme.json",
        -- theme = "dark@https://raw.githubusercontent.com/Binaryify/OneDark-Pro/refs/heads/master/themes/OneDark-Pro-night-flat.json", -- BUG: Does not work
        watermark = {
          content = "",
        },
        background = "#00000000",
        code_config = {
          font_family = "MesloLGS Nerd Font Mono",
          breadcrumbs = {
            font_family = "MesloLGS Nerd Font Mono",
          },
        },
      },
    },
  },
}
