vim.opt.hidden = true
vim.api.nvim_create_autocmd({ "FocusLost", "InsertLeave", "TextChanged" }, {
  pattern = "*",
  command = "silent! update",
})
vim.keymap.set('n', '<Leader>w', '<cmd>silent! w<cr>', { desc = 'Silent Write' })

-- Add to init.lua
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
-- In init.lua
vim.opt.directory = vim.fn.stdpath("data") .. "/swap//"

-- Indent/dedent in normal mode
vim.keymap.set('n', '<Tab>', '>>', { desc = 'Indent line' })
vim.keymap.set('n', '<S-Tab>', '<<', { desc = 'Dedent line' })

-- Previous/Next Diagnostic
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })



-- Windows (from before)
vim.keymap.set('n', '[b', '<C-w>W', { desc = 'Previous window' })
vim.keymap.set('n', ']b', '<C-w>w', { desc = 'Next window' })

-- Buffers (Files)
vim.keymap.set('n', '[h', ':bp<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', ']h', ':bn<CR>', { desc = 'Next buffer' })

-- Tabs
vim.keymap.set('n', '[t', ':tabprevious<CR>', { desc = 'Previous tab' })
vim.keymap.set('n', ']t', ':tabnext<CR>', { desc = 'Next tab' })


vim.keymap.set('n', 'db', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })


vim.g.guifont = "Fira Code:h32"
vim.g.neovide_scale_factor = 1.0
local change_scale_factor = function(delta)
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
end
vim.keymap.set("n", "<C-=>", function()
  change_scale_factor(1.25)
end)
vim.keymap.set("n", "<C-->", function()
  change_scale_factor(1/1.25)
end)

vim.g.mkdp_open_to_the_world = 1
vim.g.mkdp_open_ip = '74.50.99.25'
vim.g.mkdp_port = '8080'
	vim.g.neovide_padding_top = 32
	vim.g.neovide_padding_bottom = 32
	vim.g.neovide_padding_right = 32
	vim.g.neovide_padding_left = 32
	vim.g.neovide_transparency = 0.8
	vim.g.neovide_floating_blur_amount_x = 2.0
	vim.g.neovide_floating_blur_amount_y = 2.0
	vim.g.neovide_window_blurred = true
	vim.g.neovide_floating_shadow = true
	vim.g.neovide_floating_z_height = 10
	vim.g.neovide_light_angle_degrees = 45
	vim.g.neovide_light_radius = 5
	vim.g.neovide_scroll_animation_far_lines = 0 
	vim.g.neovide_cursor_animation_length = 0.150
	vim.g.neovide_cursor_short_animation_length = 0.04
	vim.g.neovide_cursor_antialiasing = true
	vim.g.neovide_cursor_trail_size = 1.0
	vim.g.neovide_cursor_vfx_mode = "railgun"
	vim.g.neovide_cursor_vfx_particle_phase = 6.28
require("config.lazy")
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = false,
    refresh = {
      statusline = 13200,
      tabline = 13200,
      winbar = 13200,
      refresh_time = 16, -- ~632fps
      events = {
        'WinEnter',
        'BufEnter',
        'BufWritePost',
        'SessionLoadPost',
        'FileChangedShellPost',
        'VimResized',
        'Filetype',
        'CursorMoved',
        'CursorMovedI',
        'ModeChanged',
      },
    }
  },
  sections = {
    lualine_a = {{ "fancy_mode", width = 1 }},
    lualine_b = {'fancy_lsp_servers'},
    lualine_c = {'fancy_diagnostics'},
    lualine_x = {"fancy_diff", "fancy_filename"},
    lualine_y = {"fancy_branch"},
    lualine_z = {'hostname', 'fileformat'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
require("tiny-code-action").setup({
  picker = {
    "buffer",
    opts = {
      hotkeys = true,
      hotkeys_mode = "text_diff_based",
      auto_preview = false,
      auto_accept = false,
      position = "cursor",
      winborder = "single",
      keymaps = {
        preview = "K",
        close = { "q", "<Esc>" },
        select = "<CR>",
        preview_close = { "q", "<Esc>" },
      },
      custom_keys = {
        { key = "m", pattern = "Fill match arms" },
        { key = "r", pattern = "Rename.*" },
      },
      group_icon = " └",
    },
  },
})

vim.keymap.set({ "n", "x" }, "<M-CR>", function()
  require("tiny-code-action").code_action()
end, { desc = "Code action" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.rs",
  callback = function()
    vim.lsp.buf.format { async = false }
  end,
})
require("buvvers").setup()
require("oil").setup()
vim.keymap.set("n", "<leader>bl", require("buvvers").toggle)
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.opt.clipboard = "unnamedplus"

local keymap = vim.keymap.set

-- copy to system clipboard
keymap("v", "<C-c>", '"+y')
keymap("n", "<C-c>", '"+yy')

-- paste from system clipboard
keymap("n", "<C-v>", '"+p')
keymap("v", "<C-v>", '"+p')
keymap("i", "<C-v>", '<C-r>+')
keymap("c", "<C-v>", "<C-r>+")
require("tiny-inline-diagnostic").setup()
vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
require('mini.indentscope').setup()
require('mini.map').setup()


 
-- Add to ~/.config/nvim/init.lua
vim.g.coc_global_extensions = { 'coc-clangd' }

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.updatetime = 300
vim.opt.signcolumn = 'yes'
vim.opt.laststatus = 2

-- Show coc.nvim status, including extension installation progress
vim.opt.statusline:prepend('%{coc#status()}')

local keyset = vim.keymap.set
function _G.check_back_space()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Trigger completion with Tab and navigate the completion menu
local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
keyset('i', '<TAB>', 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset('i', '<S-TAB>', [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
keyset('i', '<CR>', [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], { silent = true, expr = true })

-- Diagnostics and code navigation
keyset('n', '[c', '<Plug>(coc-diagnostic-prev)', { silent = true })
keyset('n', ']c', '<Plug>(coc-diagnostic-next)', { silent = true })
keyset('n', 'gd', '<Plug>(coc-definition)', { silent = true })
keyset('n', 'gy', '<Plug>(coc-type-definition)', { silent = true })
keyset('n', 'gi', '<Plug>(coc-implementation)', { silent = true })
keyset('n', 'gr', '<Plug>(coc-references)', { silent = true })
keyset('n', '<leader>rn', '<Plug>(coc-rename)', { silent = true })
