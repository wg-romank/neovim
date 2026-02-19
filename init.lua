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
    opts = { options = { theme = 'dracula' } } -- You can change the theme here
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

  { "catppuccin/nvim" }
})

-- 4. LSP Setup (Connecting the wires)
vim.lsp.enable('lua_ls')
-- vim.lsp.enable('pyright')
vim.lsp.enable('jedi_language_server')
vim.lsp.enable('rust_analyzer')

-- 5. Basic Keymaps
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })

vim.keymap.set("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("n", ";", ":", { remap = true, desc = "Toggle comment" })
vim.keymap.set("v", "<leader>/", "gc", { remap = true, desc = "Toggle comment" })

local ts = require('telescope.builtin')

vim.keymap.set('n', 'gd', ts.lsp_definitions, {})
vim.keymap.set('n', 'gr', ts.lsp_references, {})
vim.keymap.set('n', 'gi', ts.lsp_implementations, {})
vim.keymap.set('n', '<leader>ff', ts.find_files, {})
vim.keymap.set('n', '<leader>fw', ts.live_grep, {})
vim.keymap.set('n', '<leader>dd', function()
  ts.diagnostics({
    wrap_results = true,
    path_display = { "hidden" },
  })
end, {})

require('telescope').setup({
  pickers = {
    find_files = {
      theme = "dropdown",
    },
    diagnostics = {
      theme = "dropdown",
    }
  },
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

-- local configs = require("nvim-treesitter")
--
-- configs.setup({
--   highlight = {
--     enable = true, 
--     additional_vim_regex_highlighting = false,
--   }
-- })
--
vim.cmd.colorscheme('catppuccin')
