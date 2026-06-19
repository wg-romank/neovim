-- 1. General Settings
vim.g.loaded_python3_provider = 0
vim.g.mapleader = " "
vim.g.no_plugin_maps = true

vim.o.exrc = true
vim.opt.number = true
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.laststatus = 0
vim.opt.termguicolors = false
vim.opt.showcmd = true
vim.opt.showcmdloc = 'statusline'
vim.opt.showtabline = 0

-- make sure tabs are just buffers
vim.api.nvim_create_user_command('Tabnew', 'enew', { bang = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.showbreak = "  "
    vim.opt_local.spell = true
    -- vim.schedule(function()
    --   if vim.bo.filetype == "markdown" then
    --     require("zen-mode").open()
    --   end
    -- end)
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
      { "williamboman/mason-lspconfig.nvim", config = true, ensure_installed = { 'lua_ls', 'basedpyright', 'rust_analyzer', 'fennel_ls' } },
    },
    config = function()
      vim.lsp.config('lua_ls', {
        filetypes = { 'lua' },
        -- handlers = {
        --   ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
        --     local bufnr = vim.uri_to_bufnr(result.uri)
        --     if vim.bo[bufnr].filetype == 'fennel' then
        --       return
        --     end
        --     vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
        --   end,
        -- },
        settings = {
          Lua = {
            workspace = {
              library = {
                vim.env.VIMRUNTIME,
                "/Users/ext.roman.kotelnikov/.local/share/LuaAddons/library",
              },
              checkThirdParty = false,
            },
            diagnostics = {
              globals = { 'vim' },
            },
          },
        },
      })

      vim.lsp.config('fennel_ls', {
        -- root_dir = require('lspconfig').util.root_pattern("flsproject.fnl", ".git", "main.fnl"),
        root_dir = "/Users/ext.roman.kotelnikov/Projects/platformer"
      })

      vim.lsp.enable('lua_ls')
      vim.lsp.enable('fennel_ls')
      vim.lsp.enable('basedpyright')
      vim.lsp.enable('rust_analyzer')
    end
  },
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require('nvim-tree').setup(
        {
          on_attach = function(bufnr)
            local api = require("nvim-tree.api")

            api.config.mappings.default_on_attach(bufnr)
            -- unbind tab
            vim.keymap.set('n', '<Tab>', ':NvimTreeToggle<CR>', { buffer = bufnr })
          end,
        })
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" }
  },
  {
    'dmtrKovalenko/fff.nvim',
    build = function()
      -- downloads a prebuilt binary or falls back to cargo build
      require("fff.download").download_or_build_binary()
    end,
    -- for nixos:
    -- build = "nix run .#release",
    opts = {
      prompt = '> ',
      title = 'Files',
      layout = {
        prompt_position = "top"
      },
      debug = {
        enabled = false,
      },
      preview = {
        enabled = false
      },
      history = {
        enabled = false
      },
      frecency = {
        enabled = false
      }
    },
    lazy = false, -- the plugin lazy-initialises itself
    keys = {
      { "ff", function() require('fff').find_files() end, desc = 'FFFind files' },
      { "fw", function() require('fff').live_grep() end,  desc = 'LiFFFe grep' },
      {
        "fz",
        function() require('fff').live_grep({ grep = { modes = { 'plain' } } }) end,
        desc = 'Live fffuzy grep',
      },
      {
        "fc",
        function() require('fff').live_grep({ query = vim.fn.expand("<cword>") }) end,
        desc = 'Search current word',
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local ts = require('telescope.builtin')
      vim.keymap.set('n', 'gd', ts.lsp_definitions, { desc = 'Go to definition' })
      vim.keymap.set('n', 'gr', ts.lsp_references, { desc = 'Go to references' })
      vim.keymap.set('n', 'gi', ts.lsp_implementations, { desc = 'Go to implementation' })
      -- vim.keymap.set('n', '<leader>ff', ts.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fd', ts.diagnostics, { desc = 'Find diagnostics messages' })
      vim.keymap.set('n', '<leader>fs', function()
        require('telescope.builtin').lsp_document_symbols({
          symbols = { "Class", "Function", "Interface" },
          max_depth = 1,
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
      -- vim.keymap.set('n', '<leader>fw', ts.live_grep, { desc = 'Live grep' })
      -- vim.keymap.set('n', '<leader>fc', ts.commands, { desc = 'Find commands' })

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
    "wg-romank/telememos.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    dev = true,
    dir = '~/Projects/telememos',
    config = true
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
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    config = function()
      -- Needs a TSUpdate for required languages
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
          if lang then
            pcall(vim.treesitter.start)
          end
        end,
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
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require('dap')

      -- 1. Define the Adapter
      dap.adapters["local-lua"] = {
        type = "executable",
        command = "node",
        args = {
          -- Replace this with the actual path installed by Mason
          "/Users/ext.roman.kotelnikov/.local/share/nvim-light/mason/packages/local-lua-debugger-vscode/extension/extension/debugAdapter.js"
        },
      }

      -- 2. Define the Configuration
      dap.configurations.lua = {
        {
          name = 'Debug current file',
          type = 'local-lua',
          request = 'launch',
          cwd = "${workspaceFolder}",
          program = {
            command = "love", -- or the lua version you are using
          },
          args = { "." },
        },
      }

      local dapui = require('dapui')
      dapui.setup()
    end
  },
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
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
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
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Escape Terminal' })
vim.keymap.set('i', '<C-c>', '<Esc>', { desc = 'Ctrl+C equivalent to escape in insert mode' })
vim.keymap.set('i', '<C-x>', '<Esc>:w<CR>', { desc = 'Save buffer changes' })
vim.keymap.set('n', '<C-x>', ':w<CR>', { desc = 'Save buffer changes' })
vim.keymap.set('n', '<leader>w', ':%s/\\s\\+$//e<CR>', { desc = "Trim trailing whitespace" })

vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<CR>", { desc = "nvim-tree: toggle & find file" })

vim.keymap.set("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("n", ";", ":", { remap = true, desc = "Toggle comment" })
vim.keymap.set("v", "<leader>/", "gc", { remap = true, desc = "Toggle comment" })

vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Switch to next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Switch to previous buffer" })
vim.keymap.set("n", "<leader>x", ":bp <BAR> bd #<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>X", "<cmd>bd!<CR>", { desc = "Close! buffer" })

-- Hide terminal buffers from the buffer list
vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
    callback = function()
    vim.opt_local.buflisted = false
  end,
})

-- Hide NvimTree (and other filetree) buffers
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "NvimTree", "neo-tree" },
    callback = function()
        vim.opt_local.buflisted = false
    end,
})

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

vim.keymap.set({ "n", "x", "o" }, "]f", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]]", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]a", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[f", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[[", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[a", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.outer", "textobjects")
end)

vim.keymap.set('n', '<leader>mf', require('telememos').memos_picker, { desc = 'Find memo' })
vim.keymap.set('n', '<leader>ms', require('telememos').save_memo, { desc = 'Save memo' })
vim.keymap.set('n', '<leader>md', require('telememos').delete_memo, { desc = 'Save memo' })


-- Copy absolute path to clipboard using <leader>cp
vim.keymap.set('n', '<leader>cp', ':let @+ = expand("%")<CR>', { desc = 'Copy full path' })

