vim.filetype.add({ extension = { ink = "ink" } })

vim.lsp.config("inkd", {
  cmd = { "/tmp/shadertheory/debug/inkd" },
  filetypes = { "ink" },
  root_markers = { "Cargo.toml", ".git" },
})

vim.lsp.enable("inkd")

return {}
