-- 1. Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.loaded_python3_provider = 0

-- 2. General Settings (The "Non-Magic" parts)
vim.opt.number = true         -- Show line numbers
vim.opt.shiftwidth = 2        -- Size of an indent
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.clipboard = "unnamedplus" -- Clipboard sync
vim.g.mapleader = " "         -- Set leader key to space
vim.g.no_plugin_maps = true
vim.opt.cmdheight = 0
vim.opt.laststatus = 0
vim.opt.termguicolors = true
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" }, -- Add any filetypes here
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.showbreak = "  "
  end
})

-- 3. Configure Plugins
require("lazy").setup({
  -- LSP Management
  { 
    "neovim/nvim-lspconfig", 
    event = {"BufReadPost", "BufNewFile"}, 
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      { "williamboman/mason-lspconfig.nvim", config = true, ensure_installed = {'lua_ls', 'pyright', 'rust_analyzer'} },
    }, 
    config = function ()
      vim.lsp.enable('lua_ls')
      vim.lsp.enable('pyright')
      vim.lsp.enable('rust_analyzer')
    end
  }, -- Common configurations for LSP

  -- File Tree
  { "nvim-tree/nvim-tree.lua", config = true, dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Fuzzy Finder
  { 
    "nvim-telescope/telescope.nvim", 
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function ()

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
          lualine_b = { 'buffers', { show_filename_only = true } },
          lualine_c = {},
          lualine_x = { 'lsp_status' },
          lualine_y = { 'location' },
          lualine_z = { 'searchcount', 'selectioncount' }
        }
      })
    end
  },

  -- Syntax Highlighting
  { "nvim-treesitter/nvim-treesitter",
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
    })
  end
},

{
  "hrsh7th/nvim-cmp",
  event = "InsertEnter", -- Load only when you start typing
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- LSP suggestions
    "hrsh7th/cmp-buffer",   -- Current buffer suggestions
    "hrsh7th/cmp-path",     -- File path suggestions
    "onsails/lspkind.nvim", -- IntelliJ-style icons (optional)
    "L3MON4D3/LuaSnip",     -- Snippet engine (required by cmp)
  },
  config = function ()
    local cmp = require('cmp')
    cmp.setup({
      mapping = cmp.mapping.preset.insert({
        ['<TAB>'] = cmp.mapping.confirm({ select = true }), -- Accept suggestion with Enter
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' }, -- Suggestions from your Language Server
        { name = 'buffer' },   -- Suggestions from the current file
        { name = 'path' },     -- File system paths
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
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true -- This is equivalent to calling require("nvim-autopairs").setup{}
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
  },
}
})

-- 4. LSP Setup (Connecting the wires)

-- 5. Basic Keymaps
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })

vim.keymap.set("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("n", ";", ":", { remap = true, desc = "Toggle comment" })
vim.keymap.set("v", "<leader>/", "gc", { remap = true, desc = "Toggle comment" })

vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Switch to next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Switch to previous buffer" })
vim.keymap.set("n", "<leader>x", "<cmd>bd<CR>", { desc = "Close buffer" })

vim.keymap.set({'n', 'i'}, '<C-k>', vim.lsp.buf.signature_help, {desc = 'Trigger signature help'})

-- set keymap to toggle nvim-tree and find the current file
vim.keymap.set('n', '<leader>e', function()
  -- Check if the current buffer is the NvimTree buffer
  if vim.fn.bufname():match('NvimTree_') then
    -- If it is, switch focus to the previous window/buffer
    vim.cmd.wincmd('p')
  else
    -- Otherwise, call the NvimTreeFindFileToggle command
    vim.cmd('NvimTreeFindFileToggle')
  end
end, { desc = 'nvim-tree: toggle & find file' })

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
-- TODO: expression
-- vim.keymap.set({ "x", "o" }, "ae", function()
--   require "nvim-treesitter-textobjects.select".select_textobject("@expression.outer", "textobjects")
-- end)
-- vim.keymap.set({ "x", "o" }, "ie", function()
--   require "nvim-treesitter-textobjects.select".select_textobject("@expression.inner", "textobjects")
-- end)
