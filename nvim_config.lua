require('lualine').setup({
    options = { theme = 'gruvbox' }
})

require("gruvbox").setup({
    contrast = "hard",
    transparent_mode = true
})

require('nvim-treesitter.configs').setup({
    ensure_installed = { "c", "python", "lua", "vim", "vimdoc", "query" },
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

require("todo-comments").setup({
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
        'rfc_semicolon'
    },
    cmd = {
        'RainbowDelim',
        'RainbowDelimSimple',
        'RainbowDelimQuoted',
        'RainbowMultiDelim'
    }
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
  },
})

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

lsp_zero.setup()

local cmp = require('cmp')

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({select = false}),
        ['<c-space>'] = cmp.mapping.complete()
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'path' }
    }
})

cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' },
        { name = 'nvim_lsp_document_symbol' }
    }
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
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
