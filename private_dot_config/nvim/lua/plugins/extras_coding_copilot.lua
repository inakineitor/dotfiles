return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = {
        enabled = true,
      },
      panel = {
        enabled = false,
      },
      filetypes = {
        markdown = true,
        help = true,
        python = true,
      },
      node_host_prog = "/Users/inakiarango/.nvm/versions/node/v20.11.1/lib/node_modules",
      copilot_node_command = "/Users/inakiarango/.nvm/versions/node/v20.11.1/bin/node",
    },
  },
}
