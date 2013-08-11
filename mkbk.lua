--[[ lfs = require"lfs" --]]

prog_name = 'mkbk.lua'
prog_dir  = string.gsub(arg[0], prog_name..'$', '')
help = string.format(
'Useage: %s output_file_name md_files', prog_dir..prog_name)
table.remove(arg, 0)

pandoc_opts = "--latex-engine xelatex --chapters --toc --number-sections -V usectex:1"
pandoc_fmt  = "markdown+header_attributes+fenced_code_blocks"

out_name = arg[1]
if not out_name then
    print(help)
    os.exit(-1)
end
table.remove(arg, 1)

md_files = arg

print('generating '..out_name..'.pdf')

for i, name in ipairs{out_name..'.aux',
                      out_name..'.toc'} do
    print('clean '..name)
    os.remove(name)
end

exit_on_err = function (cmd)
    if os.getenv('VERBOSE') then
        print(cmd)
    end
    local st, reason, code = os.execute(cmd)
    if not st then
        print(string.format('-- error --\n"%s"\n-- %s with code %d --',
                            cmd, reason, code))
        os.exit(code)
    end
end

if io.open('preface.md') then
    local cmd = 'pandoc -f '..pandoc_fmt..' -o _preface.tex '..pandoc_opts..' preface.md'
    exit_on_err(cmd)
    table.insert(arg, 1, '-B _preface.tex')
end

cmd = 'pandoc --template '..prog_dir..'/default.latex -f '..pandoc_fmt..' -o '..
      out_name..'.tex '..pandoc_opts..' '..table.concat(arg, ' ')

exit_on_err(cmd)

exit_on_err('xelatex '..out_name..'.tex')
exit_on_err('xelatex '..out_name..'.tex')
