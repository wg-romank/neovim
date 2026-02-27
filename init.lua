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
  end
})

vim.diagnostic.config({
  float = {
    severity = vim.diagnostic.severity.ERROR,
  },
  virtual_text = {
    severity = vim.diagnostic.severity.ERROR,
  },
  signs = {
    severity = vim.diagnostic.severity.ERROR,
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
    'goerz/jupytext.nvim',
    version = '0.2.0',
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    event = {"BufReadPost", "BufNewFile"},
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      { "williamboman/mason-lspconfig.nvim", config = true, ensure_installed = {'lua_ls', 'basedpyright', 'rust_analyzer'} },
    },
    config = function ()
      vim.lsp.enable('lua_ls')
      vim.lsp.enable('basedpyright')
      vim.lsp.enable('rust_analyzer')
    end
  },
  { "nvim-tree/nvim-tree.lua", config = true, dependencies = { "nvim-tree/nvim-web-devicons" } },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function ()
      local ts = require('telescope.builtin')
      vim.keymap.set('n', 'gd', ts.lsp_definitions, {})
      vim.keymap.set('n', 'gr', ts.lsp_references, {})
      vim.keymap.set('n', 'gi', ts.lsp_implementations, {})
      vim.keymap.set('n', '<leader>ff', ts.find_files, {})
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
      end, {})
      vim.keymap.set('n', '<leader>fb', ts.buffers, {})
      vim.keymap.set('n', '<leader>fw', ts.live_grep, {})
      vim.keymap.set('n', '<leader>fc', ts.commands, {})

      require('telescope').setup({
        pickers = {
          find_files = { theme = 'dropdown', previewer = false },
          buffers = { theme = 'dropdown', previewer = false },
          commands = { theme = 'dropdown', previewer = false },
        }
      })

    end
  },

  -- Status Line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "mellow.nvim" },
    opts = { options = { theme = 'mellow' } },
    config = function ()
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
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" } ,
    config = function ()
      local configs = require("nvim-treesitter")

      configs.setup({
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
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
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
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
    config = function ()
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
    "mellow-theme/mellow.nvim", config = function ()
      vim.cmd.colorscheme('mellow')
    end
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
  }
})

-- 4. Configure Keymaps
vim.keymap.set('n', '<leader>tt', ':term<CR> <S-A>', {desc = 'Toggle Terminal'})
vim.keymap.set('i', '<C-c>', '<Esc>', { desc = 'Ctrl+C equivalent to escape in insert mode'})
vim.keymap.set('n', '<leader>w', ':%s/\\s\\+$//e<CR>', { desc = "Trim trailing whitespace" })

vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })

vim.keymap.set("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("n", ";", ":", { remap = true, desc = "Toggle comment" })
vim.keymap.set("v", "<leader>/", "gc", { remap = true, desc = "Toggle comment" })

vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Switch to next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Switch to previous buffer" })
vim.keymap.set("n", "<leader>x", "<cmd>bd<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>X", "<cmd>bd!<CR>", { desc = "Close buffer" })

vim.keymap.set("n", "<leader>ra", vim.lsp.buf.rename, { desc = 'LSP Rename' })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = 'LSP Code actions' })
vim.keymap.set("n", "<leader>lf", vim.diagnostic.open_float, { desc = 'Diagnostics' })
vim.keymap.set({'n', 'i'}, '<C-k>', vim.lsp.buf.signature_help, {desc = 'Trigger signature help'})

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

-- set keymap to toggle nvim-tree and find the current file
vim.keymap.set('n', '<leader>e', function()
  if vim.fn.bufname():match('NvimTree_') then
    vim.cmd.wincmd('p')
  else
    vim.cmd('NvimTreeFindFileToggle')
  end
end, { desc = 'nvim-tree: toggle & find file' })
