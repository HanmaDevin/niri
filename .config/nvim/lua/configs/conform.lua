local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    sh = { "beautysh" },
    py = { "black" },
    go = { "gofumpt" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    json = { "jq" },
    md = { "markdownfmt" },
    yaml = { "yamlfmt" },
    yml = { "yamlfmt" },
    java = { "google-java-format" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },

  formatters = {
    beautysh = {
      command = "beautysh",
      args = { "--indent-size", "2", "--variable-style", "braces", "-s", "paronly", "-" },
    },
  },
}

return options
