-- init.lua
-- Neovim configuration for Rust development

-- Basic settings
vim.opt.number = true            -- Show line numbers
vim.opt.relativenumber = true    -- Show relative line numbers
vim.opt.tabstop = 4              -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4           -- Size of an indent
vim.opt.expandtab = true         -- Use spaces instead of tabs
vim.opt.smartindent = true       -- Insert indents automatically
vim.opt.wrap = false             -- Don't wrap lines
vim.opt.swapfile = false         -- Don't create swap files
vim.opt.backup = false           -- Don't create backup files
vim.opt.undofile = true          -- Use undo files for persistent undo history
vim.opt.undodir = vim.fn.expand('~/.vim/undodir')  -- Directory for undo files
vim.opt.hlsearch = false         -- Don't highlight all search results
vim.opt.incsearch = true         -- Show incremental search results as you type
vim.opt.termguicolors = true     -- Enable 24-bit RGB colors
vim.opt.scrolloff = 8            -- Keep 8 lines visible above/below cursor when scrolling
vim.opt.signcolumn = "yes"       -- Always show the sign column
vim.opt.updatetime = 50          -- Faster update time for better UX
vim.opt.colorcolumn = "100"      -- Highlight column 100 for reference
vim.g.mapleader = " "            -- Use space as leader key
vim.opt.errorbells = false       -- Disable error bells
vim.opt.visualbell = false       -- Disable visual bell
vim.opt.showmode = false         -- Don't show mode in command line (lualine handles this)
vim.opt.confirm = false          -- Don't ask for confirmation, just do it
vim.opt.shortmess = vim.opt.shortmess + "Ic" -- Shorten messages and avoid 'press enter' prompts

-- Advanced clipboard integration - works in SSH and Docker containers
-- Check if we're in an SSH session
local in_ssh = (os.getenv("SSH_CLIENT") ~= nil) or (os.getenv("SSH_TTY") ~= nil)
-- Check if we're in a Docker container
local in_docker = io.open("/proc/1/cgroup", "r") ~= nil and io.open("/proc/1/cgroup", "r"):read("*all"):find("docker") ~= nil

-- Clipboard configuration with fallbacks for SSH/Docker
if vim.fn.has('clipboard') == 1 then
  -- If direct clipboard access is available, use it
  vim.opt.clipboard = "unnamedplus"
else
  -- If we're in SSH or Docker environment, set up OSC52 clipboard support
  -- OSC52 allows yanking to system clipboard through terminal escape sequence
  vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
      -- For ALL yanks (not just those with no register specified)
      local text = vim.fn.getreg('"')
      -- Encode the text as base64
      local encoded_text = vim.fn.system("base64 | tr -d '\n'", text)
      -- Send the OSC52 escape sequence to the terminal
      local osc52 = string.format("\x1b]52;c;%s\x07", encoded_text)
      -- Write to terminal
      io.stdout:write(osc52)
    end
  })
end

-- Ensure OSC52 works with nvim's built-in terminal too
vim.g.terminal_osc52 = ''

-- Ensure lazy.nvim is installed (replacing packer)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin management with lazy.nvim
require("lazy").setup({
  -- Theme
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  
  -- File explorer
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    }
  },
  
  -- Fuzzy finder
  "nvim-neotest/nvim-nio",
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
    }
  },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  
  -- LSP Configuration
  { 'neovim/nvim-lspconfig' },
  { 'simrat39/rust-tools.nvim' },
  
  -- Mason for managing LSP servers, formatters, and linters
  {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  
  -- Completion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-path' },
  { 'L3MON4D3/LuaSnip' },
  { 'saadparwaiz1/cmp_luasnip' },
  
  -- Treesitter for better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate'
  },
  
  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  
  -- Git integration
  { 'lewis6991/gitsigns.nvim' },
  
  -- Auto-pairs
  { 'windwp/nvim-autopairs' },

  -- Which key for key binding hints
  { 'folke/which-key.nvim' },
  
  -- Comments
  { 'numToStr/Comment.nvim' },
  
  -- Debugging
  { 'mfussenegger/nvim-dap' },
  { 'rcarriga/nvim-dap-ui' },
})

-- Theme setup
require("catppuccin").setup({
  flavour = "mocha", -- latte, frappe, macchiato, mocha
  background = { 
    light = "latte",
    dark = "mocha",
  },
  transparent_background = true,
  term_colors = true,
  dim_inactive = {
    enabled = false,
    shade = "dark",
    percentage = 0.15,
  },
  styles = {
    comments = { "italic" },
    conditionals = { "italic" },
    loops = {},
    functions = {},
    keywords = {},
    strings = {},
    variables = {},
    numbers = {},
    booleans = {},
    properties = {},
    types = {},
    operators = {},
  },
  integrations = {
    cmp = true,
    gitsigns = true,
    nvimtree = true,
    telescope = true,
    treesitter = true,
    which_key = true,
  },
})

vim.cmd.colorscheme "catppuccin"

-- Set default filetype for files with no extension to Zig
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = "*",
  callback = function()
    local filename = vim.fn.expand("%:p")
    local ext = vim.fn.fnamemodify(filename, ":e")
    -- If there's no extension and it's not a directory or special file
    if ext == "" and vim.fn.isdirectory(filename) == 0 and not string.match(filename, "^%a+://") then
      vim.bo.filetype = "zig"
    end
  end,
})

-- Mason setup
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

require("mason-lspconfig").setup({
  ensure_installed = { 
    "rust_analyzer",  -- Rust
    "zls",            -- Zig
    "eslint",         -- JavaScript
  },
  automatic_installation = true,
})

-- NvimTree setup
require('nvim-tree').setup {
  sort_by = "case_sensitive",
  view = {
    width = 30,
    adaptive_size = true,
  },
  renderer = {
    group_empty = true,
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
      glyphs = {
        default = "",
        symlink = "",
        folder = {
          arrow_closed = "",
          arrow_open = "",
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
          symlink_open = "",
        },
        git = {
          unstaged = "✗",
          staged = "✓",
          unmerged = "",
          renamed = "➜",
          untracked = "★",
          deleted = "",
          ignored = "◌",
        },
      },
    },
    highlight_git = true,
    highlight_opened_files = "all",
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = true,
    ignore = false,
  },
  actions = {
    open_file = {
      quit_on_open = false,
      resize_window = true,
    },
  },
}

-- Telescope setup
require('telescope').setup {
  defaults = {
    file_ignore_patterns = {
      "target/", -- Ignore Rust build directory
      "node_modules/",
      ".git/",
    },
    mappings = {
      i = {
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
        ["<C-q>"] = require('telescope.actions').send_to_qflist + require('telescope.actions').open_qflist,
        ["<esc>"] = require('telescope.actions').close
      },
    },
    layout_config = {
      horizontal = {
        width = 0.95,
        height = 0.85,
        preview_width = 0.55,
      },
    },
    prompt_prefix = " ",
    selection_caret = " ",
    path_display = { "truncate" },
    color_devicons = true,
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    winblend = 0,
  },
  pickers = {
    find_files = {
      hidden = true
    },
    live_grep = {
      additional_args = function()
        return {"--hidden"}
      end
    }
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  }
}

-- Load telescope extensions
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

-- LSP setup
local lspconfig = require('lspconfig')

-- Rust LSP setup via rust-tools
require('rust-tools').setup({
  server = {
    on_attach = function(client, bufnr)
      -- Enable completion triggered by <c-x><c-o>
      vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

      -- Key mappings
      local bufopts = { noremap=true, silent=true, buffer=bufnr }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
      vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
    end,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy",
        },
        cargo = {
          loadOutDirsFromCheck = true,
        },
        procMacro = {
          enable = true,
        },
      },
    },
  },
})

-- JavaScript LSP setup with JSDoc support
lspconfig.eslint.setup {}

-- Zig language settings
lspconfig.zls.setup {}

-- Setup completion
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Treesitter setup
require('nvim-treesitter.configs').setup {
  ensure_installed = { "rust", "toml", "lua", "javascript", "zig" },
  sync_install = false,
  auto_install = false, -- Disable automatic installation
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- Create a custom function to toggle distraction-free mode
vim.api.nvim_create_user_command('ToggleDistractionFree', function()
  -- Get current state - we'll toggle based on diagnostics being visible
  local current_diagnostics = vim.diagnostic.is_disabled()
  
  if current_diagnostics then
    -- Re-enable diagnostics
    vim.diagnostic.enable()
    
    -- Restore the default notification handler
    vim.notify = vim._original_notify
    
    -- Restore LSP message handlers
    vim.lsp.handlers["textDocument/hover"] = vim._original_hover_handler
    vim.lsp.handlers["textDocument/signatureHelp"] = vim._original_signature_handler
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim._original_diagnostic_handler
    
    print("Distraction-free mode disabled. LSP features restored.")
  else
    -- Save original handlers before disabling
    if not vim._original_notify then
      vim._original_notify = vim.notify
      vim._original_hover_handler = vim.lsp.handlers["textDocument/hover"]
      vim._original_signature_handler = vim.lsp.handlers["textDocument/signatureHelp"]
      vim._original_diagnostic_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
    end
    
    -- Disable diagnostics
    vim.diagnostic.disable()
    
    -- Silence notifications
    vim.notify = function(_, _, _) return end
    
    -- Disable LSP message handlers
    vim.lsp.handlers["textDocument/hover"] = function() end
    vim.lsp.handlers["textDocument/signatureHelp"] = function() end
    vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
    
    print("Distraction-free mode enabled. All interruptions suppressed.")
  end
end, {})

-- Add keybinding to toggle distraction-free mode
vim.keymap.set('n', '<leader>z', ':ToggleDistractionFree<CR>', { desc = "Toggle distraction-free mode" })

-- Lualine setup
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'catppuccin',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
  }
}

-- Gitsigns setup
require('gitsigns').setup()

-- Autopairs setup
require('nvim-autopairs').setup()

-- Which-key setup
require('which-key').setup({
  plugins = {
    marks = true,
    registers = true,
    spelling = {
      enabled = true,
      suggestions = 20,
    },
    presets = {
      operators = true,
      motions = true,
      text_objects = true,
      windows = true,
      nav = true,
      z = true,
      g = true,
    },
  },
  window = {
    border = "rounded",
    padding = { 2, 2, 2, 2 },
  },
  layout = {
    height = { min = 4, max = 25 },
    width = { min = 20, max = 50 },
    spacing = 5,
  },
  hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " },
  triggers_blacklist = {
    i = { "j", "k" },
    v = { "j", "k" },
  },
})

-- Register which-key mappings
local wk = require("which-key")
wk.register({
  f = {
    name = "Find",
    f = "Find Files",
    g = "Live Grep",
    b = "Buffers",
    h = "Help Tags",
    r = "Recent Files",
    w = "Find Word",
    m = "Marks",
    c = "Commands",
    k = "Keymaps",
  },
  b = { name = "Buffer" },
  r = { name = "Rust" },
  d = { name = "Debug" },
  g = { name = "Git" },
  j = { name = "JavaScript" },
  z = { name = "Zig" },
}, { prefix = "<leader>" })

-- Comment setup
require('Comment').setup()

-- DAP setup for debugging
local dap = require('dap')
local dapui = require('dapui')

dapui.setup({
  icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Expand lines larger than the window
  expand_lines = vim.fn.has("nvim-0.7") == 1,
  layouts = {
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40, -- 40 columns
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    },
  },
  controls = {
    -- Requires Neovim nightly (or 0.8 when released)
    enabled = true,
    -- Display controls in this element
    element = "repl",
    icons = {
      pause = "",
      play = "",
      step_into = "",
      step_over = "",
      step_out = "",
      step_back = "",
      run_last = "",
      terminate = "",
    },
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "rounded", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = { 
    max_type_length = nil,
    max_value_lines = 100,
  }
})

-- Configure Rust debugging
dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode', -- Adjust this path to your system
  name = 'lldb'
}

dap.configurations.rust = {
  {
    name = "Launch",
    type = "lldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
    runInTerminal = false,
  },
}

-- DAP UI auto open/close
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- Key mappings for debugging
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = "Set conditional breakpoint" })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = "Continue" })
vim.keymap.set('n', '<leader>dn', dap.step_over, { desc = "Step over" })
vim.keymap.set('n', '<leader>di', dap.step_into, { desc = "Step into" })
vim.keymap.set('n', '<leader>do', dap.step_out, { desc = "Step out" })
vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = "Terminate" })
vim.keymap.set('n', '<leader>dR', dap.run_to_cursor, { desc = "Run to cursor" })
vim.keymap.set('n', '<leader>dE', function()
  dapui.eval(vim.fn.input('Expression: '))
end, { desc = "Evaluate expression" })
vim.keymap.set('n', '<leader>dC', function()
  dap.set_breakpoint(nil, nil, vim.fn.input('Log message: '))
end, { desc = "Breakpoint with log message" })
vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = "Open REPL" })
vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = "Run last" })

-- Custom key mappings
-- General workflow keys
vim.keymap.set('n', '<leader>w', '<cmd>silent w<CR>', { desc = "Save file" })
vim.keymap.set('n', '<leader>q', '<cmd>silent q<CR>', { desc = "Quit" })
vim.keymap.set('n', '<leader>Q', '<cmd>silent q!<CR>', { desc = "Force quit" })
vim.keymap.set('n', '<C-s>', '<cmd>silent w<CR>', { desc = "Save file" })
vim.keymap.set('n', '<leader>bk', '<cmd>silent bdelete<CR>', { desc = "Kill buffer" })
vim.keymap.set('n', '<leader>/', '<cmd>silent nohlsearch<CR>', { desc = "Clear search highlight" })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Move to left window" })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Move to bottom window" })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Move to top window" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Move to right window" })

-- Resize windows
vim.keymap.set('n', '<C-Up>', '<cmd>resize -2<CR>', { desc = "Decrease window height" })
vim.keymap.set('n', '<C-Down>', '<cmd>resize +2<CR>', { desc = "Increase window height" })
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -2<CR>', { desc = "Decrease window width" })
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +2<CR>', { desc = "Increase window width" })

-- Buffer navigation
vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>', { desc = "Next buffer" })
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<CR>', { desc = "Previous buffer" })

-- Better indenting
vim.keymap.set('v', '<', '<gv', { desc = "Outdent line" })
vim.keymap.set('v', '>', '>gv', { desc = "Indent line" })

-- Move text up and down
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = "Move text down" })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = "Move text up" })

-- File explorer
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true, desc = "Toggle file explorer" })

-- Telescope keybindings
local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, { desc = "Find files" })
vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, { desc = "Live grep" })
vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, { desc = "Find buffers" })
vim.keymap.set('n', '<leader>fh', telescope_builtin.help_tags, { desc = "Help tags" })
vim.keymap.set('n', '<leader>fr', telescope_builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set('n', '<leader>fw', telescope_builtin.grep_string, { desc = "Find word under cursor" })
vim.keymap.set('n', '<leader>fm', telescope_builtin.marks, { desc = "Find marks" })
vim.keymap.set('n', '<leader>fc', telescope_builtin.commands, { desc = "Find commands" })
vim.keymap.set('n', '<leader>fk', telescope_builtin.keymaps, { desc = "Find keymaps" })
vim.keymap.set('n', '<C-p>', telescope_builtin.git_files, { desc = "Find git files" })

-- Rust-specific shortcuts
vim.keymap.set('n', '<leader>rr', ':RustRunnables<CR>', { noremap = true, silent = true, desc = "Rust runnables" })
vim.keymap.set('n', '<leader>rt', ':RustTest<CR>', { noremap = true, silent = true, desc = "Rust test" })
vim.keymap.set('n', '<leader>rm', ':RustExpandMacro<CR>', { noremap = true, silent = true, desc = "Rust expand macro" })
vim.keymap.set('n', '<leader>rc', ':RustOpenCargo<CR>', { noremap = true, silent = true, desc = "Rust open cargo" })
vim.keymap.set('n', '<leader>rp', ':RustParentModule<CR>', { noremap = true, silent = true, desc = "Rust parent module" })
vim.keymap.set('n', '<leader>rd', ':RustDebuggables<CR>', { noremap = true, silent = true, desc = "Rust debuggables" })

-- Create autocmd group for Rust settings
local rust_group = vim.api.nvim_create_augroup('RustSettings', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'rust',
  callback = function()
    -- Auto-format on save
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = 0,
      callback = function() vim.lsp.buf.format() end,
    })
  end,
  group = rust_group,
})

-- JavaScript settings with JSDoc focus
local js_group = vim.api.nvim_create_augroup('JavaScriptSettings', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'javascript'},
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    -- Auto-format on save
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = 0,
      callback = function() vim.lsp.buf.format() end,
    })
  end,
  group = js_group,
})
