vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- stylua: ignore
colors = {
    dragonBlack0  = '#0d0c0c',
    dragonBlack1  = '#12120f',
    dragonBlack2  = '#1D1C19',
    dragonBlack3  = '#181616',
    dragonBlack4  = '#282727',
    dragonBlack5  = '#393836',
    dragonBlack6  = '#625e5a',
    dragonWhite   = '#c4c9c4',
    dragonGreen   = '#80a980',
    dragonGreen2  = '#869a74',
    dragonPink    = '#a18ea3',
    dragonOrange  = '#b68a6f',
    dragonOrange2 = '#b9846e',
    dragonGray    = '#a6a69a',
    dragonGray2   = '#9e9a90',
    dragonGray3   = '#788381',
    -- dragonBlue    = '#6caeca',
    dragonBlue2   = '#83a1b0',
    dragonViolet  = '#838da7',
    dragonRed     = '#c4635c',
    dragonAqua    = '#89a4a1',
    dragonAsh     = '#717c71',
    dragonTeal    = '#8d9ab5',
    dragonYellow  = '#c4ae7e',
}

local lualine_theme = {
	normal = {
		a = { fg = colors.dragonBlack0, bg = colors.dragonBlue2, gui = 'bold' },
		b = { fg = colors.dragonWhite, bg = colors.dragonBlack0 },
		c = { fg = colors.dragonWhite, bg = colors.dragonBlack0 },
	},
	insert = { a = { fg = colors.dragonBlack0, bg = colors.dragonGreen2 } },
	visual = { a = { fg = colors.dragonBlack0, bg = colors.dragonOrange } },
	replace = { a = { fg = colors.dragonBlack0, bg = colors.dragonRed } },
	inactive = {
		a = { fg = colors.dragonWhite, bg = colors.dragonBlack0 },
		b = { fg = colors.dragonBlack6, bg = colors.dragonBlack0 },
		c = { fg = colors.dragonWhite },
	},
}

require('lualine').setup({
	options = {
		theme = lualine_theme,
		section_separators = '',
		component_separators = '',
		globalstatus = true,
		always_divide_middle = false,
	},
	sections = {
		lualine_a = { {
			'mode',
			fmt = function(str)
				return str:sub(1, 1)
			end,
		} },
		lualine_b = { {
			'windows',
			disabled_buftypes = { 'quickfix', 'prompt' },
		} },
		lualine_c = {
			'%=',
			{
				'filename',
				path = 1,
			},
		},
		lualine_x = { 'branch', 'diff', 'filetype' },
		lualine_y = { 'progress' },
		lualine_z = { 'location', 'searchcount' },
	},
	tabline = {
		lualine_a = {
			{
				'tabs',
				mode = 2,
				max_length = vim.o.columns,
				show_modified_status = false,
			},
		},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = { 'tabs' },
	},
})

require('kanagawa').setup({
	compile = true,
	colors = {
		pallette = colors,
		theme = {
			all = {
				ui = {
					bg_gutter = 'none',
				},
			},
		},
	},
	overrides = function(colors)
		local theme = colors.theme
		return {
			NormalFloat = { bg = 'none' },
			FloatBorder = { bg = 'none' },
			FloatTitle = { bg = 'none' },

			-- Save an hlgroup with dark background and dimmed foreground
			-- so that you can use it where your still want darker windows.
			-- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
			NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

			-- Popular plugins that open floats will link to NormalFloat by default;
			-- set their background accordingly if you wish to keep them dark and borderless
			LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
			MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
		}
	end,
})

require('nvim-treesitter.configs').setup({
	ensure_installed = { 'c', 'python', 'lua', 'vim', 'vimdoc', 'query' },
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
		disable = function(lang, buf)
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,
		additional_vim_regex_highlighting = false,
	},
})

require('todo-comments').setup({
	signs = false, -- show icons in the signs column
	-- * after: highlights after the keyword (todo text)
	highlight = {
		pattern = [[.*<(KEYWORDS)\s*]], -- pattern or table of patterns, used for highlighting (vim regex)
	},
	search = {
		pattern = [[\b(KEYWORDS)\b]], -- ripgrep regex
	},
})

require('rainbow_csv').setup({
	config = true,
	ft = {
		'csv',
		'tsv',
		'csv_semicolon',
		'csv_whitespace',
		'csv_pipe',
		'rfc_csv',
		'rfc_semicolon',
	},
	cmd = {
		'RainbowDelim',
		'RainbowDelimSimple',
		'RainbowDelimQuoted',
		'RainbowMultiDelim',
	},
})

require('telescope').setup()

local lsp_zero = require('lsp-zero').preset({})

require('mason').setup({})
require('mason-lspconfig').setup({
	--  ensure_installed = {'tsserver', 'rust_analyzer'},
	handlers = {
		lsp_zero.default_setup,
		jedi_language_server = function()
			require('lspconfig').jedi_language_server.setup({
				--       initializationOptions = {
				diagnostics = {
					enable = true,
				},
				--      },
			})
		end,
		lua_ls = function()
			require('lspconfig').lua_ls.setup({
				cmd = { 'lua-language-server' },
				settings = {
					Lua = {
						diagnostics = {
							globals = { 'vim' },
						},
					},
				},
			})
		end,
	},
})

lsp_zero.on_attach(function(client, bufnr)
	-- see :help lsp-zero-keybindings
	-- to learn the available actions
	lsp_zero.default_keymaps({ buffer = bufnr })

	-- vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', {buffer = bufnr})
	vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { buffer = bufnr })
	vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })
	-- vim.keymap.set("n", "<leader>F", vim.lsp.buf.format, { buffer = bufnr })
end)

lsp_zero.setup()

local cmp = require('cmp')

cmp.setup({
	mapping = cmp.mapping.preset.insert({
		['<CR>'] = cmp.mapping.confirm({ select = false }),
		['<c-space>'] = cmp.mapping.complete(),
	}),
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'buffer' },
		{ name = 'path' },
	},
})

cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' },
		{ name = 'nvim_lsp_document_symbol' },
	},
})

cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' },
	}, {
		{ name = 'cmdline' },
	}),
})

require('illuminate').configure({
	providers = {
		'lsp',
		'treesitter',
		'regex',
	},
	delay = 0,
	filetypes_denylist = {},
	filetypes_allowlist = {},
	under_cursor = true,
	-- large_file_cutoff: number of lines at which to use large_file_config
	-- The `under_cursor` option is disabled when this cutoff is hit
	large_file_cutoff = nil,
	-- Supports the same keys passed to .configure
	-- If nil, vim-illuminate will be disabled for large files.
	large_file_overrides = nil,
	-- min_count_to_highlight: minimum number of matches required to perform highlighting
	min_count_to_highlight = 2,
	case_insensitive_regex = false,
})

require('Comment').setup()

local function nvim_on_attach(bufnr)
	local api = require('nvim-tree.api')

	local function opts(desc)
		return {
			desc = 'nvim-tree: ' .. desc,
			buffer = bufnr,
			noremap = true,
			silent = true,
			nowait = true,
		}
	end

	-- BEGIN_DEFAULT_ON_ATTACH
	vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node, opts('CD'))
	vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer, opts('Open: In Place'))
	vim.keymap.set('n', '<C-k>', api.node.show_info_popup, opts('Info'))
	vim.keymap.set('n', '<C-r>', api.fs.rename_sub, opts('Rename: Omit Filename'))
	vim.keymap.set('n', '<C-t>', api.node.open.tab, opts('Open: New Tab'))
	vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
	vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts('Open: Horizontal Split'))
	vim.keymap.set('n', '<BS>', api.node.navigate.parent_close, opts('Close Directory'))
	vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
	vim.keymap.set('n', '<Tab>', api.node.open.preview, opts('Open Preview'))
	vim.keymap.set('n', '>', api.node.navigate.sibling.next, opts('Next Sibling'))
	vim.keymap.set('n', '<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
	vim.keymap.set('n', '.', api.node.run.cmd, opts('Run Command'))
	vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts('Up'))
	vim.keymap.set('n', 'a', api.fs.create, opts('Create File Or Directory'))
	vim.keymap.set('n', 'bd', api.marks.bulk.delete, opts('Delete Bookmarked'))
	vim.keymap.set('n', 'bt', api.marks.bulk.trash, opts('Trash Bookmarked'))
	vim.keymap.set('n', 'bmv', api.marks.bulk.move, opts('Move Bookmarked'))
	vim.keymap.set('n', 'B', api.tree.toggle_no_buffer_filter, opts('Toggle Filter: No Buffer'))
	vim.keymap.set('n', 'c', api.fs.copy.node, opts('Copy'))
	vim.keymap.set('n', 'C', api.tree.toggle_git_clean_filter, opts('Toggle Filter: Git Clean'))
	vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts('Prev Git'))
	vim.keymap.set('n', ']c', api.node.navigate.git.next, opts('Next Git'))
	vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
	vim.keymap.set('n', 'D', api.fs.trash, opts('Trash'))
	vim.keymap.set('n', 'E', api.tree.expand_all, opts('Expand All'))
	vim.keymap.set('n', 'e', api.fs.rename_basename, opts('Rename: Basename'))
	vim.keymap.set('n', ']e', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
	vim.keymap.set('n', '[e', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
	vim.keymap.set('n', 'F', api.live_filter.clear, opts('Live Filter: Clear'))
	vim.keymap.set('n', 'f', api.live_filter.start, opts('Live Filter: Start'))
	vim.keymap.set('n', 'g?', api.tree.toggle_help, opts('Help'))
	vim.keymap.set('n', 'gy', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
	vim.keymap.set('n', 'ge', api.fs.copy.basename, opts('Copy Basename'))
	vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle Filter: Dotfiles'))
	vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts('Toggle Filter: Git Ignore'))
	vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts('Last Sibling'))
	vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts('First Sibling'))
	vim.keymap.set('n', 'L', api.node.open.toggle_group_empty, opts('Toggle Group Empty'))
	vim.keymap.set('n', 'M', api.tree.toggle_no_bookmark_filter, opts('Toggle Filter: No Bookmark'))
	vim.keymap.set('n', 'm', api.marks.toggle, opts('Toggle Bookmark'))
	vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
	vim.keymap.set('n', 'O', api.node.open.no_window_picker, opts('Open: No Window Picker'))
	vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))
	vim.keymap.set('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
	vim.keymap.set('n', 'q', api.tree.close, opts('Close'))
	vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
	vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
	vim.keymap.set('n', 's', api.node.run.system, opts('Run System'))
	vim.keymap.set('n', 'S', api.tree.search_node, opts('Search'))
	vim.keymap.set('n', 'u', api.fs.rename_full, opts('Rename: Full Path'))
	vim.keymap.set('n', 'U', api.tree.toggle_custom_filter, opts('Toggle Filter: Hidden'))
	vim.keymap.set('n', 'W', api.tree.collapse_all, opts('Collapse'))
	vim.keymap.set('n', 'x', api.fs.cut, opts('Cut'))
	vim.keymap.set('n', 'y', api.fs.copy.filename, opts('Copy Name'))
	vim.keymap.set('n', 'Y', api.fs.copy.relative_path, opts('Copy Relative Path'))
	vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
	vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))
	vim.keymap.set('n', '_', ':NvimTreeResize -5<CR>', opts('Resize: +5'))
	vim.keymap.set('n', '-', ':NvimTreeResize -5<CR>', opts('Resize: +5'))
	vim.keymap.set('n', '+', ':NvimTreeResize +5<CR>', opts('Resize: +5'))
	vim.keymap.set('n', '=', ':NvimTreeResize +5<CR>', opts('Resize: +5'))
end

require('nvim-tree').setup({
	on_attach = nvim_on_attach,
	hijack_cursor = true,
	renderer = {
		add_trailing = true,
		icons = {
			show = {
				folder_arrow = false,
			},
			git_placement = 'after',
		},
	},
	git = { enable = true },
	update_focused_file = { enable = true },
	actions = {
		open_file = {
			window_picker = { enable = false },
		},
	},
	filters = {
		dotfiles = false,
		git_ignored = false,
	},
})

conform = require('conform')
conform.setup({
	formatters_by_ft = {
		-- Conform will run multiple formatters sequentially
		-- Use a sub-list to run only the first available formatter
		python = { 'isort', 'ruff_format' },
		lua = { 'stylua' },
	},
})
conform.formatters.stylua = {
	prepend_args = { '--quote-style=AutoPreferSingle' },
}

local function Format(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			['end'] = { args.line2, end_line:len() },
		}
	end
	require('conform').format({ async = true, lsp_fallback = true, range = range })
end
vim.api.nvim_create_user_command('Format', Format, { range = true })
vim.keymap.set({ 'n', 'v' }, '<leader>F', function()
	require('conform').format({ async = true, lsp_fallback = true })
end)
