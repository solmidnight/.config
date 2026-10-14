local function coc_diagnostics()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

    local raw = vim.fn.CocAction("diagnosticList") or {}
  local seen, items = {}, {}
  for _, item in ipairs(raw) do
    local key = table.concat({
      item.file or "",
      tostring(item.lnum or 0),
      tostring(item.col or 0),
      item.message or "",
    }, "|")
    if not seen[key] then
      seen[key] = true
      table.insert(items, item)
    end
  end
  if vim.tbl_isempty(items) then
    vim.notify("No CoC diagnostics", vim.log.levels.INFO)
    return
  end

  pickers.new({}, {
    prompt_title = "CoC Diagnostics",
    finder = finders.new_table({
      results = items,
      entry_maker = function(item)
        local file = item.file or ""
        local msg = (item.message or ""):gsub("\n", " ")
        local level = item.level or item.severity or ""
        local text = string.format("%s:%d:%d [%s] %s",
          vim.fn.fnamemodify(file, ":~:."), item.lnum or 1, item.col or 1, level, msg)
        return {
          value = item,
          display = text,
          ordinal = text,
          filename = file,
          lnum = item.lnum or 1,
          col = item.col or 1,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = conf.grep_previewer({}),
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        actions.close(bufnr)
        local sel = action_state.get_selected_entry()
        if sel then
          vim.cmd("edit " .. vim.fn.fnameescape(sel.filename))
          vim.api.nvim_win_set_cursor(0, { sel.lnum, math.max(sel.col - 1, 0) })
        end
      end)
      return true
    end,
  }):find()
end
return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files (filename)" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep (content)" },
	{ "<leader>fd", coc_diagnostics, desc = "CoC diagnostics (workspace)" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
          file_ignore_patterns = {
            "node_modules/",
            "%.git/",
            "build/",
            "target/",
            "%.o$",
            "%.a$",
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<esc>"] = actions.close,
            },
            n = {
              ["q"] = actions.close,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "--glob", "!.git" },
          },
          live_grep = {
            additional_args = function()
              return { "--hidden", "--glob", "!.git" }
            end,
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
