-- 1. Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 2. General Settings (The "Non-Magic" parts)
vim.opt.number = true         -- Show line numbers
vim.opt.shiftwidth = 2        -- Size of an indent
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.clipboard = "unnamedplus" -- Clipboard sync
vim.g.mapleader = " "         -- Set leader key to space

-- 3. Configure Plugins
require("lazy").setup({
  -- LSP Management
  { "williamboman/mason.nvim", config = true }, -- Portable package manager
  { "williamboman/mason-lspconfig.nvim", config = true }, -- Bridges mason and lspconfig
  { "neovim/nvim-lspconfig" }, -- Common configurations for LSP

  -- File Tree
  { "nvim-tree/nvim-tree.lua", config = true, dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Fuzzy Finder
  { 
    "nvim-telescope/telescope.nvim", 
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Status Line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { theme = 'mellow' } }
  },

  -- Syntax Highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", -- Load only when you start typing
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP suggestions
      "hrsh7th/cmp-buffer",   -- Current buffer suggestions
      "hrsh7th/cmp-path",     -- File path suggestions
      "onsails/lspkind.nvim", -- IntelliJ-style icons (optional)
      "L3MON4D3/LuaSnip",     -- Snippet engine (required by cmp)
    }
  },

  { "mellow-theme/mellow.nvim" },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>dd",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>fs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
    },
  }
})

-- 4. LSP Setup (Connecting the wires)
vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = {
        -- Stops the LSP from reporting errors in these folders
        ignore = { ".venv", "**/site-packages", "build" },
        -- Only show diagnostics for files currently open in a buffer
        diagnosticMode = "openFilesOnly",
        -- Keeps type-hinting working for external libs without deep scanning
        useLibraryCodeForTypes = true,
        autoSearchPaths = false,
      },
    },
  },
})

vim.lsp.enable('lua_ls')
vim.lsp.enable('pyright')
-- vim.lsp.enable('jedi_language_server')
vim.lsp.enable('rust_analyzer')

-- 5. Basic Keymaps
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })

vim.keymap.set("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("n", ";", ":", { remap = true, desc = "Toggle comment" })
vim.keymap.set("v", "<leader>/", "gc", { remap = true, desc = "Toggle comment" })

vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Switch to next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Switch to previous buffer" })
vim.keymap.set("n", "<leader>x", "<cmd>bd<CR>", { desc = "Close buffer" })


local ts = require('telescope.builtin')

vim.keymap.set('n', 'gd', ts.lsp_definitions, {})
vim.keymap.set('n', 'gr', ts.lsp_references, {})
vim.keymap.set('n', 'gi', ts.lsp_implementations, {})
vim.keymap.set('n', '<leader>ff', ts.find_files, {})
vim.keymap.set('n', '<leader>fb', ts.buffers, {})
vim.keymap.set('n', '<leader>fw', ts.live_grep, {})

require('telescope').setup({
  pickers = {
    find_files = { theme = 'dropdown', previewer = false },
    buffers = { theme = 'dropdown', previewer = false },
  }
})

local cmp = require('cmp')
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<TAB>'] = cmp.mapping.confirm({ select = true }), -- Accept suggestion with Enter
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' }, -- Suggestions from your Language Server
    { name = 'buffer' },   -- Suggestions from the current file
    { name = 'path' },     -- File system paths
  })
})

local configs = require("nvim-treesitter")

configs.setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  }
})

local lualine = require('lualine')

lualine.setup({
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'buffers', { show_filename_only = true } },
    lualine_c = {},
    lualine_x = {},
    lualine_y = { 'location' },
    lualine_z = { 'searchcount', 'selectioncount' }
  }
})

vim.cmd.colorscheme('mellow')
