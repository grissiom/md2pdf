#!/usr/bin/env lua

prog_name = 'mkat.lua'
prog_dir  = string.gsub(arg[0], prog_name..'$', '')
help = string.format('Useage: %s output_file_name md_files',
                     prog_dir..prog_name)
-- table.remove(arg, 0)

if #arg < 2 then
    print(help)
    os.exit(-1)
end

out_name = table.remove(arg, 1)

md_files = arg

pandoc_opts = " --latex-engine xelatex --toc --number-sections -V usectex:1 -V isartical:1"

dofile(prog_dir..'/run.lua')
