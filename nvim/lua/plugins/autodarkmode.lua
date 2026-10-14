return-- Lua
{
  "f-person/auto-dark-mode.nvim",
  opts = {
    set_dark_mode = function()
    vim.o.background = "dark"
    vim.cmd.colorscheme("catppuccin-mocha")
    end,
    set_light_mode = function()
    vim.o.background = "light"
    vim.cmd.colorscheme("catppuccin-latte")
    end,
    update_interval = 3000,
    fallback = "light"
}
}
