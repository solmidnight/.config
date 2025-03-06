-- init.lua
-- Neovim configuration for Rust development with enhanced debugging support

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
  
  -- Enhanced debugging setup
  { 'mfussenegger/nvim-dap' },
  { 'rcarriga/nvim-dap-ui' },
  { 'theHamsta/nvim-dap-virtual-text' }, -- Virtual text for debug info
  { 'nvim-telescope/telescope-dap.nvim' }, -- Telescope integration for DAP
  { 'jbyuki/one-small-step-for-vimkind' }, -- Lua debugger
  { 'leoluz/nvim-dap-go' }, -- Go debugger
  
  -- Specific Rust debugging support
  { 'simrat39/rust-tools.nvim' }, -- Already included above, but kept here for clarity
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
    dap = {
      enabled = true,
      enable_ui = true, -- enable nvim-dap-ui
    },
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
    "codelldb",       -- Important for Rust debugging
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
    },
    dap = {
      -- Enable or disable dap extension features
    }
  }
}

-- Load telescope extensions
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
pcall(require('telescope').load_extension, 'dap')

-- Enhanced DAP Setup
local dap = require('dap')
local dapui = require('dapui')
local dap_virtual_text = require('nvim-dap-virtual-text')

-- Setup virtual text for debugging
dap_virtual_text.setup({
  enabled = true,                  -- Enable virtual text
  enabled_commands = true,         -- Create commands
  highlight_changed_variables = true, -- Highlight changed values
  highlight_new_as_changed = false, -- Highlight new variables
  show_stop_reason = true,        -- Show stop reason
  commented = false,              -- Prefix virtual text with comment
  only_first_definition = true,   -- Only show virtual text for first definition
  all_references = false,         -- Show virtual text on all references
})

-- DAP UI Setup
dapui.setup({
  icons = { 
    expanded = "▾", 
    collapsed = "▸", 
    current_frame = "▸" 
  },
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
    -- Requires Neovim 0.8
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

-- Find and use the correct path for codelldb binary from Mason
local extension_path
local codelldb_path
local liblldb_path

-- First, check if Mason has installed codelldb
local mason_registry = require("mason-registry")
local codelldb_pkg = mason_registry.get_package("codelldb")
if codelldb_pkg and codelldb_pkg:is_installed() then
  extension_path = codelldb_pkg:get_install_path()
  
  -- Set paths based on OS
  if vim.fn.has("mac") == 1 then
    codelldb_path = extension_path .. "/extension/adapter/codelldb"
    liblldb_path = extension_path .. "/extension/lldb/lib/liblldb.dylib"
  elseif vim.fn.has("unix") == 1 then
    codelldb_path = extension_path .. "/extension/adapter/codelldb"
    liblldb_path = extension_path .. "/extension/lldb/lib/liblldb.so"
  elseif vim.fn.has("win32") == 1 then
    codelldb_path = extension_path .. "\\extension\\adapter\\codelldb.exe"
    liblldb_path = extension_path .. "\\extension\\lldb\\bin\\liblldb.dll"
  end
else
  -- Fallback paths
  if vim.fn.has("mac") == 1 then
    codelldb_path = "/usr/local/bin/codelldb"
    liblldb_path = "/usr/local/opt/llvm/lib/liblldb.dylib"
  elseif vim.fn.has("unix") == 1 then
    codelldb_path = "/usr/bin/codelldb"
    liblldb_path = "/usr/lib/liblldb.so"
  end
end

-- Configure the Rust DAP adapter
dap.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  executable = {
    command = codelldb_path,
    args = {"--port", "${port}"},
    -- On windows you may have to uncomment this:
    -- detached = false,
  }
}

-- Configure Rust DAP
dap.configurations.rust = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
    runInTerminal = false,
    -- If specified, use the liblldb from this path
    -- initCommands = function()
    --   if liblldb_path then
    --     return { "command script import " .. liblldb_path }
    --   else
    --     return {}
    --   end
    -- end,
  },
  {
    name = "Attach to process",
    type = "codelldb",
    request = "attach",
    processId = require('dap.utils').pick_process,
    cwd = '${workspaceFolder}',
  },
  {
    name = "Run with arguments",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
    end,
    cwd = '${workspaceFolder}',
    args = function()
      local args_string = vim.fn.input('Arguments: ')
      return vim.split(args_string, " ")
    end,
    stopOnEntry = false,
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
-- Basic debugging operations
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = "Set conditional breakpoint" })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = "Continue" })
vim.keymap.set('n', '<leader>dn', dap.step_over, { desc = "Step over" })
vim.keymap.set('n', '<leader>di', dap.step_into, { desc = "Step into" })
vim.keymap.set('n', '<leader>do', dap.step_out, { desc = "Step out" })
vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = "Terminate" })

-- Advanced debugging operations
vim.keymap.set('n', '<leader>dR', dap.run_to_cursor, { desc = "Run to cursor" })
vim.keymap.set('n', '<leader>dE', function()
  dapui.eval(vim.fn.input('Expression: '))
end, { desc = "Evaluate expression" })
vim.keymap.set('n', '<leader>dC', function()
  dap.set_breakpoint(nil, nil, vim.fn.input('Log message: '))
end, { desc = "Breakpoint with log message" })
vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = "Open REPL" })
vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = "Run last" })

-- DAP UI specific keybindings
vim.keymap.set('n', '<leader>dut', dapui.toggle, { desc = "Toggle DAP UI" })
vim.keymap.set('n', '<leader>due', dapui.eval, { desc = "Evaluate expression (UI)" })
vim.keymap.set('v', '<leader>due', dapui.eval, { desc = "Evaluate selection (UI)" })
vim.keymap.set('n', '<leader>duf', function() 
  dapui.float_element("scopes") 
end, { desc = "Float scopes" })

-- Rust-specific debugging
vim.keymap.set('n', '<leader>drd', function()
  -- Check if rust-analyzer is available
  local clients = vim.lsp.get_active_clients()
  local has_rust = false
  for _, client in pairs(clients) do
    if client.name == "rust_analyzer" then
      has_rust = true
      break
    end
  end
  
  if has_rust then
    -- Use rust-tools debuggables
    require('rust-tools').debuggables.debuggables()
  else
    -- Fallback to regular dap
    dap.continue()
    print("rust-analyzer not active, using regular debugger")
  end
end, { desc = "Run Rust debuggables" })

-- Telescope DAP integration
vim.keymap.set('n', '<leader>dft', function() require('telescope').extensions.dap.frames{} end, { desc = "DAP list frames" })
vim.keymap.set('n', '<leader>dfc', function() require('telescope').extensions.dap.commands{} end, { desc = "DAP list commands" })
vim.keymap.set('n', '<leader>dfb', function() require('telescope').extensions.dap.list_breakpoints{} end, { desc = "DAP list breakpoints" })
vim.keymap.set('n', '<leader>dfv', function() require('telescope').extensions.dap.variables{} end, { desc = "DAP list variables" })

-- LSP setup
local lspconfig = require('lspconfig')

-- Rust LSP setup via rust-tools with debugging integration
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
          buildScripts = {
            enable = true,
          },
        },
        procMacro = {
          enable = true,
        },
      },
    },
  },
  dap = {
    adapter = {
      type = 'executable',
      command = codelldb_path,
      name = 'rt_lldb',
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

-- Lualine setup with DAP integration
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'catppuccin',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {
      {
        function()
          return require("dap").status()
        end,
        cond = function()
          return package.loaded["dap"] and require("dap").status() ~= ""
        end,
      },
      'encoding', 'fileformat', 'filetype'
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
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
  d = { 
    name = "Debug",
    b = "Toggle Breakpoint",
    B = "Conditional Breakpoint",
    c = "Continue",
    n = "Step Over",
    i = "Step Into",
    o = "Step Out",
    t = "Terminate",
    r = "Open REPL",
    l = "Run Last",
    R = "Run to Cursor",
    E = "Evaluate Expression",
    C = "Breakpoint with Message",
    u = {
      name = "UI",
      t = "Toggle UI",
      e = "Evaluate",
      f = "Float Element",
    },
    f = {
      name = "Find",
      t = "Frames",
      c = "Commands",
      b = "Breakpoints",
      v = "Variables",
    },
    r = {
      name = "Rust",
      d = "Rust Debuggables",
    },
  },
  g = { name = "Git" },
  j = { name = "JavaScript" },
  z = { name = "Zig" },
}, { prefix = "<leader>" })

-- Comment setup
require('Comment').setup()

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

-- Updated Telescope code actions mapping
vim.keymap.set("n", "<leader>ca", function()
  -- Check if telescope is available first to avoid nil errors
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then
    -- Fallback to native LSP if telescope isn't available
    vim.lsp.buf.code_action()
    return
  end
  
  -- Use the correct function name for your Telescope version
  if telescope.lsp_code_actions then
    telescope.lsp_code_actions()
  elseif telescope.lsp_actions then
    telescope.lsp_actions()
  else
    -- Another fallback to built-in code actions
    vim.lsp.buf.code_action()
  end
end, { desc = "Code Actions (Telescope)" })
vim.keymap.set('n', '<leader>ww', '<C-w>k', { desc = "Move to window above" })

-- Space + A: Move to the window on the left
vim.keymap.set('n', '<leader>aa', '<C-w>h', { desc = "Move to window left" })

-- Space + S: Move to the window below
vim.keymap.set('n', '<leader>ss', '<C-w>j', { desc = "Move to window below" })

-- Space + D: Move to the window on the right
vim.keymap.set('n', '<leader>dd', '<C-w>l', { desc = "Move to window right" })

-- Optional: Space + E to equalize window sizes
vim.keymap.set('n', '<leader>ee', '<C-w>=', { desc = "Equalize window sizes" })

-- Optional: Space + R to rotate windows
vim.keymap.set('n', '<leader>rr', '<C-w>r', { desc = "Rotate windows" })

-- Vertical split (creates a new window to the right)
vim.keymap.set('n', '<leader>sv', ':vsplit<CR>', { desc = "Split window vertically", silent = true })

-- Horizontal split (creates a new window below)
vim.keymap.set('n', '<leader>sh', ':split<CR>', { desc = "Split window horizontally", silent = true })

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

-- Debug Utils - Automatically locate executables for Cargo projects
local function get_cargo_targets()
  local targets = {}
  local cargo_path = vim.fn.getcwd() .. "/Cargo.toml"
  
  -- Check if Cargo.toml exists
  if vim.fn.filereadable(cargo_path) == 0 then
    return targets
  end
  
  -- Use cargo metadata to get target information
  local metadata_cmd = "cargo metadata --format-version 1 --no-deps"
  local metadata_handle = io.popen(metadata_cmd)
  
  if metadata_handle then
    local metadata_output = metadata_handle:read("*a")
    metadata_handle:close()
    
    -- Parse JSON output (basic parsing)
    local decoded_ok, metadata = pcall(vim.fn.json_decode, metadata_output)
    if decoded_ok and metadata and metadata.packages and #metadata.packages > 0 then
      local package = metadata.packages[1] -- Take the first package
      
      -- Process targets
      for _, target in ipairs(package.targets or {}) do
        if target.kind then
          for _, kind in ipairs(target.kind) do
            if kind == "bin" or kind == "example" or kind == "test" then
              local bin_name = target.name
              local bin_path = vim.fn.getcwd() .. "/target/debug/" .. bin_name
              table.insert(targets, {name = bin_name, path = bin_path})
            end
          end
        end
      end
    end
  end
  
  return targets
end

-- Add a command to list and select cargo targets for debugging
vim.api.nvim_create_user_command('RustDebugTargets', function()
  local targets = get_cargo_targets()
  
  if #targets == 0 then
    print("No Rust binary targets found. Are you in a Cargo project?")
    return
  end
  
  -- Print targets with numbers for selection
  print("Available binary targets:")
  for i, target in ipairs(targets) do
    print(i .. ": " .. target.name .. " (" .. target.path .. ")")
  end
  
  -- Ask for selection
  vim.ui.input({prompt = "Select target number to debug: "}, function(input)
    if not input or input == "" then return end
    
    local idx = tonumber(input)
    if not idx or idx < 1 or idx > #targets then
      print("Invalid selection")
      return
    end
    
    local selected = targets[idx]
    print("Debugging: " .. selected.name)
    
    -- Configure and start debugging session
    dap.run({
      type = "codelldb",
      request = "launch",
      program = selected.path,
      cwd = vim.fn.getcwd(),
      stopOnEntry = false,
      args = {},
      runInTerminal = false,
    })
  end)
end, {})

-- Add shortcut for listing Rust debug targets
vim.keymap.set('n', '<leader>drl', ':RustDebugTargets<CR>', { noremap = true, silent = true, desc = "List Rust debug targets" })

-- Create sign definitions for DAP breakpoints
vim.fn.sign_define('DapBreakpoint', { text='●', texthl='DiagnosticSignError', linehl='', numhl='' })
vim.fn.sign_define('DapBreakpointCondition', { text='◆', texthl='DiagnosticSignWarn', linehl='', numhl='' })
vim.fn.sign_define('DapLogPoint', { text='◆', texthl='DiagnosticSignInfo', linehl='', numhl='' })
vim.fn.sign_define('DapStopped', { text='→', texthl='DiagnosticSignHint', linehl='DebuggerLine', numhl='' })
vim.fn.sign_define('DapBreakpointRejected', { text='●', texthl='DiagnosticSignHint', linehl='', numhl='' })

-- Add Rust hover actions to show type details
-- Only if rust-tools is present
if package.loaded["rust-tools"] then
  vim.keymap.set("n", "<leader>ra", function()
    require("rust-tools").hover_actions.hover_actions()
  end, { desc = "Rust hover actions" })
end

-- Create a function to auto-build and debug Rust
function BuildAndDebugRust()
  -- Check if it's a Rust project
  if vim.fn.filereadable("Cargo.toml") == 0 then
    print("Not a Cargo project (no Cargo.toml found)")
    return
  end
  
  -- Build the project
  vim.cmd("echo 'Building project...'")
  
  -- Run cargo build in a job so we don't block neovim
  local job_id = vim.fn.jobstart("cargo build", {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        print("Build failed with exit code: " .. exit_code)
        return
      end
      
      print("Build successful, starting debugger...")
      
      -- Get targets and pick the first binary if available
      local targets = get_cargo_targets()
      if #targets == 0 then
        print("No binary targets found")
        return
      end
      
      -- Debug the first binary
      local target_path = targets[1].path
      dap.run({
        type = "codelldb",
        request = "launch",
        program = target_path,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
        runInTerminal = false,
      })
    end,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.schedule(function()
          for _, line in ipairs(data) do
            if line ~= "" then
              print(line)
            end
          end
        end)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.schedule(function()
          for _, line in ipairs(data) do
            if line ~= "" then
              print(line)
            end
          end
        end)
      end
    end
  })
  
  if job_id <= 0 then
    print("Failed to start cargo build")
  end
end

-- Add command for quick build and debug
vim.api.nvim_create_user_command('RustBuildAndDebug', BuildAndDebugRust, {})
vim.keymap.set('n', '<leader>drb', ':RustBuildAndDebug<CR>', { noremap = true, desc = "Build and debug Rust" })

-- Add this to your init.lua
-- Function to find build.rs file path
local function find_build_rs()
    local build_rs_path = vim.fn.getcwd() .. "/build.rs"
    if vim.fn.filereadable(build_rs_path) == 1 then
        return build_rs_path
    end
    return nil
end

-- Add configuration for debugging build.rs
table.insert(dap.configurations.rust, {
    name = "Debug build.rs",
    type = "codelldb",
    request = "launch",
    program = function()
        -- Create a temporary executable for build.rs
        local build_rs = find_build_rs()
        if not build_rs then
            print("No build.rs found in project root")
            return nil
        end
        
        -- Create a shell command to compile build.rs to a temporary executable
        local tmp_dir = vim.fn.expand("$HOME/.cache/nvim/rust_build_debug")
        vim.fn.mkdir(tmp_dir, "p")
        local exec_path = tmp_dir .. "/build_rs_debug"
        
        -- Compile using rustc with debug info
        local cmd = string.format(
            "rustc %s -o %s -g --edition=2021", 
            build_rs, 
            exec_path
        )
        
        print("Compiling build.rs: " .. cmd)
        local result = vim.fn.system(cmd)
        
        if vim.v.shell_error ~= 0 then
            print("Failed to compile build.rs: " .. result)
            return nil
        end
        
        return exec_path
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
    env = function()
        -- Extract environment variables from cargo
        local env_output = vim.fn.system("cargo build -v")
        local env_vars = {}
        
        -- Try to extract environment variables that Cargo uses
        for var in string.gmatch(env_output, "([A-Z_]+=\\S+)") do
            local name, value = string.match(var, "([A-Z_]+)=(.*)")
            if name and value then
                env_vars[name] = value
            end
        end
        
        -- Add common environment variables for build scripts
        env_vars["CARGO_MANIFEST_DIR"] = vim.fn.getcwd()
        env_vars["OUT_DIR"] = vim.fn.getcwd() .. "/target/debug/build/your_crate_name/out"
        
        return env_vars
    end,
    sourceLanguages = {"rust"},
})
vim.keymap.set('n', '<leader>drb', function()
    -- Find the right configuration
    for _, config in ipairs(dap.configurations.rust) do
        if config.name == "Debug build.rs" then
            dap.run(config)
            return
        end
    end
    print("Debug build.rs configuration not found")
end, { desc = "Debug build.rs" })
