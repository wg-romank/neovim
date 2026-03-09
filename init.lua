-- 1. General Settings
vim.g.loaded_python3_provider = 0
vim.g.mapleader = " "
vim.g.no_plugin_maps = true

vim.opt.number = true
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.laststatus = 0
vim.opt.termguicolors = true
vim.opt.showcmd = true
vim.opt.showcmdloc = 'statusline'

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.showbreak = "  "
    vim.opt_local.spell = true
    vim.schedule(function()
      if vim.bo.filetype == "markdown" then
        require("zen-mode").open()
      end
    end)
  end
})

vim.diagnostic.config({
  float = {
    severity = vim.diagnostic.severity.WARNING,
  },
  virtual_text = {
    severity = vim.diagnostic.severity.ERROR,
  },
  signs = {
    severity = vim.diagnostic.severity.WARNING,
  },
  underline = false,
})

-- 2. Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 3. Configure Plugins
require("lazy").setup({
  {
    "neovim/nvim-lspconfig",
    -- event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim",           config = true },
      { "williamboman/mason-lspconfig.nvim", config = true, ensure_installed = { 'lua_ls', 'basedpyright', 'rust_analyzer' } },
    },
    config = function()
      vim.lsp.enable('lua_ls')
      vim.lsp.enable('basedpyright')
      vim.lsp.enable('rust_analyzer')
    end
  },
  { "nvim-tree/nvim-tree.lua", config = true, dependencies = { "nvim-tree/nvim-web-devicons" } },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local ts = require('telescope.builtin')
      vim.keymap.set('n', 'gd', ts.lsp_definitions, { desc = 'Go to definition' })
      vim.keymap.set('n', 'gr', ts.lsp_references, { desc = 'Go to references' })
      vim.keymap.set('n', 'gi', ts.lsp_implementations, { desc = 'Go to implementation' })
      vim.keymap.set('n', '<leader>ff', ts.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fs', function()
        require('telescope.builtin').lsp_document_symbols({
          show_line = true,
          tiebreak = function(current_entry, existing_entry, _)
            return current_entry.lnum < existing_entry.lnum
          end,
          layout_strategy = 'vertical',
          layout_config = {
            anchor = "E",
            width = 0.45,
            height = 0.99,
            prompt_position = "top",
          },
          sorting_strategy = "ascending",
          previewer = false,
        })
      end, { desc = 'Find symbols' })
      vim.keymap.set('n', '<leader>fb', ts.buffers, { desc = 'Find buffers' })
      vim.keymap.set('n', '<leader>fw', ts.live_grep, { desc = 'Live grep' })
      vim.keymap.set('n', '<leader>fc', ts.commands, { desc = 'Find commands' })

      require('telescope').setup({
        pickers = {
          find_files = { theme = 'dropdown', previewer = false },
          buffers = { theme = 'dropdown', previewer = false },
          commands = { theme = 'dropdown', previewer = false },
        }
      })
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "mellow.nvim" },
    opts = { options = { theme = 'mellow' } },
    config = function()
      local lualine = require('lualine')

      lualine.setup({
        options = {
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { '%S' },
          lualine_c = { 'buffers', { show_filename_only = true } },
          lualine_x = { 'lsp_status' },
          lualine_y = { 'location' },
          lualine_z = { 'searchcount', 'selectioncount' }
        }
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    config = function()
      local configs = require("nvim-treesitter")

      configs.setup({
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true
        }
      })

      require('nvim-treesitter-textobjects').setup({
        select = {
          enable = true,
          lookahead = true,
          include_surrounding_whitespace = true,
          selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@function.outer'] = 'V',
            ['@class.outer'] = 'V',
          },
        },
        {
          move = {
            enable = true,
            set_jumps = true, -- Add jumps to jumplist
          },
        }
      })
    end
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "onsails/lspkind.nvim",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<TAB>'] = cmp.mapping.confirm({ select = true }), -- Accept suggestion with Enter
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end
  },
  {
    "mellow-theme/mellow.nvim",
    config = function()
      vim.cmd.colorscheme('mellow')
    end
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,

    -- Completion for `blink.cmp`
    -- dependencies = { "saghen/blink.cmp" },
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        width = 120,      -- Narrower buffer width
        options = {
          number = false, -- Hide line numbers
          relativenumber = false,
        }
      },
    },
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
    },
  },
  -- Experimental
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    'goerz/jupytext.nvim',
    version = '0.2.0',
    opts = {},
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/nvim-nio"
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            runner = "pytest",
            python = ''
          }),
        },
      })
    end
  },
})

-- 4. Configure Keymaps
vim.keymap.set('n', '<leader>tt', ':term<CR> <S-A>', { desc = 'Toggle Terminal' })
vim.keymap.set('i', '<C-c>', '<Esc>', { desc = 'Ctrl+C equivalent to escape in insert mode' })
vim.keymap.set('n', '<leader>w', ':%s/\\s\\+$//e<CR>', { desc = "Trim trailing whitespace" })

vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<CR>", { desc = "nvim-tree: toggle & find file" })

vim.keymap.set("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("n", ";", ":", { remap = true, desc = "Toggle comment" })
vim.keymap.set("v", "<leader>/", "gc", { remap = true, desc = "Toggle comment" })

vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Switch to next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Switch to previous buffer" })
vim.keymap.set("n", "<leader>x", "<cmd>bd<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>X", "<cmd>bd!<CR>", { desc = "Close! buffer" })

vim.keymap.set("n", "<leader>ra", vim.lsp.buf.rename, { desc = 'LSP Rename' })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = 'LSP Code actions' })
vim.keymap.set("n", "<leader>lf", vim.diagnostic.open_float, { desc = 'Diagnostics' })
vim.keymap.set({ 'n', 'i' }, '<C-k>', vim.lsp.buf.signature_help, { desc = 'Trigger signature help' })

vim.keymap.set({ "n", "v" }, "=", function()
  vim.lsp.buf.format()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end, { desc = "Format file or range with LSP" })

vim.keymap.set({ "x", "o" }, "af", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "if", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ac", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ic", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "aa", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@parameter.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ia", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@parameter.inner", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]m", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]]", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]a", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[m", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[[", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[a", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.outer", "textobjects")
end)

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local curl = require("plenary.curl")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local cache_path = vim.fn.stdpath("data") .. "/usememos_cache.json"

local function save_to_cache(data)
  local file = io.open(cache_path, "w")
  if file then
    file:write(vim.json.encode(data))
    file:close()
  end
end

local function load_from_cache()
  local file = io.open(cache_path, "r")
  if not file then return nil end
  local content = file:read("*all")
  file:close()
  return vim.json.decode(content)
end

-- Configuration: Replace with your actual instance details
local MEMOS_URL = vim.env.MEMOS_URL
local API_TOKEN = vim.env.MEMOS_TOKEN

local _memos_cache = nil
function fetch_memos()
  local url = MEMOS_URL .. '/api/v1/memos'
  local all_memos = {}
  local next_page_token = ''
  repeat
    local res = curl.get(url, {
      headers = {
        Authorization = "Bearer " .. API_TOKEN,
        ["Content-Type"] = "application/json",
      },
      query = {
        pageSize = 100,
        pageToken = next_page_token
      }
    })
  
    if res.status ~= 200 then
      vim.notify("API Error: " .. res.status, vim.log.levels.ERROR)
      return nil
    end
  
    local ok, decoded = pcall(vim.fn.json_decode, res.body)
    if decoded.memos then
      for _, memo in ipairs(decoded.memos) do
        table.insert(all_memos, memo)
      end
    end
    next_page_token = decoded.nextPageToken or ""
  until next_page_token == ''
  return all_memos
end

function sync_memo_to_api(bufnr, memo_id)
  local api_url = MEMOS_URL .. '/api/v1'
  local token = API_TOKEN

  -- If we have an ID, we target the specific resource and use PATCH
  local url = memo_id and (api_url .. "/" .. memo_id) or api_url
  local method = memo_id and "patch" or "post"
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")

  -- Perform the async request
  curl[method](url, {
    body = vim.fn.json_encode({ content = content }),
    headers = {
      auth = "Bearer " .. token,
      content_type = "application/json",
    },
    callback = function(res)
      vim.schedule(function()
        if res.status >= 200 and res.status < 300 then
          vim.api.nvim_buf_set_option(bufnr, 'modified', false)
          print("Memo synced successfully (" .. res.status .. ")")
        else
          print("Error: " .. res.status .. " - " .. res.body)
        end
      end)
    end,
  })
end

function memos_picker(opts)
  opts = opts or {}
  _memos_cache = load_from_cache()
  if not _memos_cache then
    _memos_cache = fetch_memos()
    save_to_cache(_memos_cache)
  end

  if not _memos_cache then return end

  local layout_opts = {
    previewer = true,
    layout_strategy = 'vertical',
    layout_config = {
      width = 0.8,
      preview_cutoff = 0,
      height = 0.8,
      prompt_position = "top",
    },
    sorting_strategy = "ascending", -- Required for prompt_position = "top"
  }
  opts = vim.tbl_deep_extend("force", layout_opts, opts)

  pickers.new(opts, {
    prompt_title = "Memos",
    finder = finders.new_table({
      results = _memos_cache,
      entry_maker = function(data)
        local content = data.content or ""
        local heading = content:match("^#+%s*(.-)\n")

        local display = nil
        if heading then
          -- local icon, hl = devicons.get_icon("x", "markdown")
          -- display = string.format("%s %s", icon, heading) --, { { 0, #icon }, hl }
          display = heading
        else
          display = data.content
          if #display > 120 then
            display = display:sub(1, 117) .. "..."
          end
        end

        return {
          value = data,
          memo_id = data.name,
          display = display,
          heading = heading,
          ordinal = heading or content,
          content = content,
        }
      end,
    }),
    sorter = require("telescope.sorters").get_fzy_sorter(opts),
    -- sorter = conf.generic_sorter(opts),
    previewer = previewers.new_buffer_previewer({
      title = "Memo Preview",
      define_preview = function(self, entry, status)
        -- Fill the preview buffer with the full note content
        local lines = vim.split(entry.content, "\n")
        -- table.insert(lines, "")
        -- table.insert(lines, "---")
        -- table.insert(lines, table.concat(entry.value.tags, ", "))
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        -- Optional: set filetype to markdown for highlighting
        vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")
        local winid = self.state.winid
        vim.api.nvim_win_set_option(winid, "wrap", true)      -- Enable visual wrapping
        vim.api.nvim_win_set_option(winid, "linebreak", true) -- Wrap at word boundaries
        vim.api.nvim_win_set_option(winid, "list", false)     -- Required for linebreak to work
        vim.api.nvim_win_set_option(winid, "number", false)
        vim.api.nvim_win_set_option(winid, "relativenumber", false)
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        -- 1. Close the picker
        actions.close(prompt_bufnr)

        -- 2. Get the selected entry
        local selection = action_state.get_selected_entry()
        local content = selection.content or ""

        -- 3. Create a new buffer
        local bufnr = vim.api.nvim_create_buf(true, false) -- listed, scratch

        -- 4. Fill with content
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))

        -- 5. Set buffer options
        vim.api.nvim_buf_set_name(bufnr, selection.heading or selection.memo_id)
        vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
        vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe") -- delete on close

        vim.api.nvim_create_autocmd("BufWriteCmd", {
          buffer = bufnr,
          callback = function()
            -- memo_id is captured here via closure
            print("Saving to memo ID: " .. tostring(selection.memo_id))
            -- Perform API call...
            sync_memo_to_api(bufnr, selection.memo_id)
          end,
        })

        -- 6. Switch to the buffer
        vim.api.nvim_set_current_buf(bufnr)
      end)
      return true
    end,
  }):find()
end

-- Usage: :lua memos_picker()
vim.keymap.set('n', '<leader>mm', memos_picker, { desc = 'Find Memos' })
