-- ========================================================================== --
-- ==           {{{   EDITOR SETTINGS                                      == --
-- ========================================================================== --

local opt = vim.opt -- alias for vim.opt
local key = vim.keymap.set -- alias for keymap.set
local api = vim.api -- alias for vim.api
local g = vim.g -- alias for vim.g

opt.number = true -- numbers in the left column
opt.relativenumber = true -- relative numbers on by default
opt.mouse = "a"  -- enable mouse support in all modes
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- ignore case if search pattern is all lowercase
opt.gdefault = true -- replace all matches in a line by default
opt.hlsearch = false -- do not highlight search results by default
opt.wrap = false -- do not wrap lines by default
opt.breakindent = true -- indent wrapped lines
opt.tabstop = 2 -- number of spaces a tab counts for
opt.shiftwidth = 2 -- number of spaces used for each step of (auto)indent
opt.expandtab = true -- convert tabs to spaces
opt.autoindent = true -- copy indent from current line when starting a new line
opt.signcolumn = "yes" -- always show the sign column
opt.clipboard = "unnamedplus" -- use system clipboard
opt.cursorline = true -- highlight the current line
opt.undodir = vim.fn.stdpath("cache") .. "/undo" -- persistent undo in directory
opt.undofile = true -- persistent undo in file
opt.backup = false -- do not create backup files
opt.writebackup = false -- do not create backup files
opt.foldmethod = "expr" -- folding method expression
opt.foldexpr = "nvim_treesitter#foldexpr()" -- folding method for treesitter
opt.foldlevel = 99 -- folding level to open all folds by default 
-- }}}
-- ========================================================================== --
-- ==           {{{   KEY BINDINGS                                         == --
-- ========================================================================== --

g.mapleader = " " -- space as leader
key("n", "<leader><space>", ":", { desc = "Command Mode" }) -- command mode
key("n", "<leader>ec", ":e $MYVIMRC<CR>", { desc = "Edit Config" }) -- edit neovim config file
key("i", "jk", "<esc>", { desc = "Go to Normal Mode" }) -- go to normal mode
key("n", "q", "<C-r>", { desc = "Redo" }) -- redo

key({ "n", "x", "o" }, "<leader>h", "^", { desc = "Move to beginning of line" }) -- move to beginning of line
key({ "n", "x", "o" }, "<leader>l", "g_", { desc = "Move to end of line" }) -- move to end of line
key("n", "<leader>a", ":keepjumps normal! ggVG<cr>", { desc = "Select all" }) -- select all

key("n", "<leader>nn", ":set nonumber!<CR>", { desc =  "Toggle line numbers" }) -- toggle line numbers
key("n", "<leader>nr", ":set relativenumber!<CR>", { desc = "Toggle relative line numbers" }) -- toggle relative line numbers
key("n", "<leader>wr", ":set wrap! wrap?<CR>", { desc = "Toggle line wrap" }) -- toggle line wrap

key({ "n", "x" }, "x", '"_x') -- delete without yanking

key("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" }) -- save
key("n", "<leader>bq", "<cmd>bdelete<cr>", { desc = "Close buffer" }) -- close buffer
key("n", "<leader>bl", "<cmd>buffer #<cr>", { desc = "Next buffer" }) -- go to last buffer

key("n", "<leader>ca", ":lua vim.lsp.buf.code_action()<CR>", { desc = "Code Action" }) -- code action on current line
-- }}}
-- ========================================================================== --
-- ==           {{{  COMMANDS                                              == --
-- ========================================================================== --

api.nvim_create_user_command("ReloadConfig", "source $MYVIMRC", {}) -- reload config

local group = api.nvim_create_augroup("user_cmds", { clear = true }) -- augroup for user commands 

api.nvim_create_autocmd("TextYankPost", { -- highlight on yank
	desc = "Highlight on yank", 
	group = group, 
	callback = function() 
		vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
	end,
})

api.nvim_create_autocmd("FileType", { -- quit help buffers
	pattern = { "help", "man" },
	group = group,
	command = "nnoremap <buffer> q <cmd>quit<cr>",
})

api.nvim_set_keymap('c', '<Down>', 'v:lua.get_wildmenu_key("<right>", "<down>")', { expr = true }) -- cusror down in wildmenu
api.nvim_set_keymap('c', '<Up>', 'v:lua.get_wildmenu_key("<left>", "<up>")', { expr = true }) -- cusror up in wildmenu

function _G.get_wildmenu_key(key_wildmenu, key_regular)
return vim.fn.wildmenumode() ~= 0 and key_wildmenu or key_regular
end


-- }}}
-- ========================================================================== --
-- ==           {{{          PLUGINS                                == --
-- ========================================================================== --

local lazy = {} -- lazy.nvim plugin manager 

function lazy.install(path) -- install lazy.nvim
	if not vim.loop.fs_stat(path) then
		print("Installing lazy.nvim....")
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable", -- latest stable release
			path,
		})
	end
end

function lazy.setup(plugins) -- setup lazy.nvim
	-- You can "comment out" the line below after lazy.nvim is installed
	-- lazy.install(lazy.path)

	opt.rtp:prepend(lazy.path) -- add lazy.nvim to runtime path
	require("lazy").setup(plugins, lazy.opts) -- setup plugins
end

lazy.path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" -- path to lazy.nvim
lazy.opts = {} -- options

lazy.setup({ 
	-- Theming
	{ "folke/tokyonight.nvim" }, -- colorscheme 
	{ "bluz71/vim-nightfly-colors", name = "nightfly", lazy = false, priority = 1000 }, -- colorscheme
	{ "tanvirtin/monokai.nvim" }, -- colorscheme
	{ "bluz71/nvim-linefly" }, -- statusline plugin
	{
		"echasnovski/mini.indentscope", -- indent guides 
		version = false, -- wait till new 0.7.0 release to put it back on semver
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			-- symbol = "▏",
			symbol = "│",
			options = { try_as_border = true },
		},
		init = function()
			api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"dashboard",
					"lazy",
					"mason",
					"notify",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},

	{
		"folke/noice.nvim", -- fancy command line/search bar
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
	},

	-- Fuzzy finder
	{ "nvim-telescope/telescope.nvim", branch = "0.1.x" }, -- fuzzy finder/file navigator plus more
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, -- dependency for better sorting performance

	-- Git
	{ "lewis6991/gitsigns.nvim" }, -- show git changes in the gutter
	{ "tpope/vim-fugitive" }, -- git commands in nvim

	-- Code manipulation
	{ "nvim-treesitter/nvim-treesitter" }, -- syntax highlighting and indentation
	{ "nvim-treesitter/nvim-treesitter-textobjects" }, -- text objects for treesitter
	{ "numToStr/Comment.nvim" }, -- comment out lines
	{ "tpope/vim-surround" }, -- surround text with quotes, brackets, etc.
	{
		"windwp/nvim-autopairs", -- autopairs for treesitter and others
		event = "InsertEnter",
		opts = {}, -- this is equalent to setup({}) function
	},
	{ "wellle/targets.vim" }, -- text objects for targets
	{ "tpope/vim-repeat" }, -- enable repeating supported plugin maps with .
	{
		"folke/flash.nvim", -- jump to character by pressing s then the character
		event = "VeryLazy",
		vscode = true,
		opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" }, -- jump to character
    },
	},


{ "moll/vim-bbye" }, -- close buffer
{ "nvim-lua/plenary.nvim" }, -- dependency for better sorting performance

{ "neovim/nvim-lspconfig" }, -- lsp configuration
{ "williamboman/mason.nvim" }, -- lsp installer
{ "williamboman/mason-lspconfig.nvim" }, -- lsp installer config

-- Autocomplete
{ "hrsh7th/nvim-cmp" }, -- Autocompletion plugin
{ "hrsh7th/cmp-buffer" }, -- buffer completions
{ "hrsh7th/cmp-path" }, -- path completions
{ "saadparwaiz1/cmp_luasnip" }, -- snippet completions
{ "hrsh7th/cmp-nvim-lsp" }, -- lsp completions

-- Snippets
{
  "L3MON4D3/LuaSnip", -- snippet engine
  dependencies = {
    "rafamadriz/friendly-snippets", -- a bunch of snippets to use
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  opts = {
    history = true,
    delete_check_events = "TextChanged",
  },
  -- stylua: ignore
  keys = {
    {
      "<tab>",
      function()
        return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
      end,
      expr = true, silent = true, mode = "i",
    },
    { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
    { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
  },
	},
	-- which key

	{
		"folke/which-key.nvim", -- show keybindings in popup
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
		},
	},
})
-- }}}
-- ========================================================================== --
-- ==           {{{       PLUGIN CONFIGURATION                         == --
-- ========================================================================== --

---
-- Colorscheme
---
opt.termguicolors = true 
require("tokyonight").setup({
	transparent = true,
})

vim.cmd.colorscheme("tokyonight") -- set colorscheme

---
-- Treesitter
---
-- See :help nvim-treesitter-modules
require("nvim-treesitter.configs").setup({ -- treesitter configuration
	highlight = {
		enable = true,
	},
	-- :help nvim-treesitter-textobjects-modules
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
	},
	ensure_installed = {
		"javascript",
		"astro",
		"c",
		"go",
		"markdown_inline",
		"typescript",
		"tsx",
		"lua",
        "luadoc",
		"vim",
		"vimdoc",
		"css",
		"json",
		"zig",
	},
})

---
-- Comment.nvim
---
require("Comment").setup({})

---
-- Gitsigns
---
-- See :help gitsigns-usage
require("gitsigns").setup({ -- setup gitsigns
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "➤" },
		topdelete = { text = "➤" },
		changedelete = { text = "▎" },
	},
})

---
-- Telescope
---
-- See :help telescope.builtin
key("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>") -- find recent files
key("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers
key("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files
key("n", "<leader>fh", "<cmd>Telescope find_files hidden=true<cr>") -- find hidden files
key("n", "<leader>fg", "<cmd>Telescope live_grep<cr>") -- find text in files
key("n", "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>") -- show diagnostics for current buffer
key("n", "<leader>sD", "<cmd>Telescope diagnostics<cr>") -- show diagnostics for all buffers
key("n", "<leader>fs", "<cmd>Telescope current_buffer_fuzzy_find<cr>") -- fuzzy find in current buffer
key("n", "<leader>sk", "<cmd>Telescope keymaps<cr>") -- show keymaps -- this can be used instead of whichkey for a slimmer config

require("telescope").load_extension("fzf") -- load fzf

require("telescope").setup({ -- setup telescope
	defaults = {
		file_ignore_patterns = {
			"node_modules",
			".git",
		},
	},
})

---
-- Luasnip (snippet engine)
---
-- See :help luasnip-loaders
require("luasnip.loaders.from_vscode").lazy_load() -- load snippets

---
-- nvim-cmp (autocomplete)
---
opt.completeopt = { "menu", "menuone", "noselect" } -- autocomplete

local cmp = require("cmp")
local luasnip = require("luasnip")
local select_opts = { behavior = cmp.SelectBehavior.Select }

-- See :help cmp-config
cmp.setup({ -- setup cmp
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	sources = {
		{ name = "path" },
		{ name = "nvim_lsp" },
		{ name = "buffer", keyword_length = 3 },
		{ name = "luasnip", keyword_length = 2 },
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	completion = {
		completeopt = "menu,menuone,noinsert",
	},
	formatting = {
		fields = { "menu", "abbr", "kind" },
		format = function(entry, item)
			local menu_icon = {
				nvim_lsp = "λ",
				luasnip = "⋗",
				buffer = "Ω",
				path = "🖫",
			}

			item.menu = menu_icon[entry.source.name]
			return item
		end,
	},
	-- See :help cmp-mapping
	mapping = {
		["<Up>"] = cmp.mapping.select_prev_item(select_opts),
		["<Down>"] = cmp.mapping.select_next_item(select_opts),

		["<C-p>"] = cmp.mapping.select_prev_item(select_opts),
		["<C-n>"] = cmp.mapping.select_next_item(select_opts),

		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),

		["<C-e>"] = cmp.mapping.abort(),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<CR>"] = cmp.mapping.confirm({ select = false }),

		["<C-f>"] = cmp.mapping(function(fallback)
			if luasnip.jumpable(1) then
				luasnip.jump(1)
			else
				fallback()
			end
		end, { "i", "s" }),

		["<C-b>"] = cmp.mapping(function(fallback)
			if luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	},
})

---
-- LSP config
---
local lspconfig = require("lspconfig")

-- Capabilities: make LSP completion feature-complete with nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Optional: one place to put per-buffer keymaps & extras
local on_attach = function(client, bufnr)
  local bufmap = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  bufmap("n", "K", vim.lsp.buf.hover, "LSP: Hover")
  bufmap("n", "gd", vim.lsp.buf.definition, "LSP: Goto Definition")
  bufmap("n", "gD", vim.lsp.buf.declaration, "LSP: Goto Declaration")
  bufmap("n", "gi", vim.lsp.buf.implementation, "LSP: Goto Implementation")
  bufmap("n", "gr", vim.lsp.buf.references, "LSP: References")
  bufmap("n", "gl", vim.diagnostic.open_float, "LSP: Line Diagnostics")
  bufmap("n", "[d", vim.diagnostic.goto_prev, "LSP: Prev Diagnostic")
  bufmap("n", "]d", vim.diagnostic.goto_next, "LSP: Next Diagnostic")

  -- Inlay hints (Neovim 0.10+)
  if vim.lsp.inlay_hint and client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

-- Diagnostic UI
local sign = function(opts)
  vim.fn.sign_define(opts.name, { texthl = opts.name, text = opts.text, numhl = "" })
end
sign({ name = "DiagnosticSignError", text = "✘" })
sign({ name = "DiagnosticSignWarn",  text = "▲" })
sign({ name = "DiagnosticSignHint",  text = "⚑" })
sign({ name = "DiagnosticSignInfo",  text = "»" })

vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = { border = "rounded", source = "always" },
})
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

---
-- Mason (+ mason-lspconfig) bootstrapping
---
require("mason").setup({
  ui = { border = "rounded" },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "astro",
    "clangd",
    "emmet_ls",
    "gopls",
    "lua_ls",
    "ts_ls",       -- new name for tsserver
    "tailwindcss",
    "eslint",
    "html",
    "cssls",
    "zls",
  },
  handlers = {
    -- Default handler for every server
    function(server_name)
      lspconfig[server_name].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end,

    -- Typescript/Javascript
    ["ts_ls"] = function()
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        root_dir = lspconfig.util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git"),
        single_file_support = false,
        settings = {
          completions = { completeFunctionCalls = true },
        },
      })
    end,

    -- Lua (tweak for Neovim runtime)
    ["lua_ls"] = function()
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                "${3rd}/luv/library",
              },
            },
          },
        },
      })
    end,
  },
})

-- (Removed the second, duplicate manual `ts_ls.setup` block)
-- }}}
-- # vim:foldmethod=marker:foldlevel=0
