augroup VimSnakemake
  autocmd!
  autocmd BufNewFile,BufRead Snakefile,*.snakefile,*.snake,*.smk setlocal filetype=snakemake
augroup END
