require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "lua_ls",
  "bashls",
  "gopls",
  "jdtls",
  "rust_analyzer",
  "clangd",
  "dockerls",
  "gradle_ls",
  "hyprls",
  "jedi_language_server",
  "texlab",
  "yamlls",
  "jsonls",
  "marksman",
}
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
