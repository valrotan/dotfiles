require('lualine').setup{
    options = { theme = 'gruvbox' }
}

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
