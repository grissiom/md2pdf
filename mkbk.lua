#!/usr/bin/env lua

prog_name = 'mkbk.lua'
prog_dir  = string.gsub(arg[0], prog_name..'$', '')
help = string.format('Useage: %s output_file_name md_files',
                     prog_dir..prog_name)
table.remove(arg, 0)

if #arg < 2 then
    print(help)
    os.exit(-1)
end

out_name = table.remove(arg, 1)

md_files = arg

print('generating '..out_name..'.pdf')

local verbose_log = function (str)
    if os.getenv('VERBOSE') then
        print(str)
    end
end

for _, name in ipairs{out_name..'.aux',
                      out_name..'.toc'} do
    verbose_log('clean '..name)
    os.remove(name)
end

-- read the mds
content = {md = {}, latex = {}}
do
    local pre = io.open('preface.md')
    if pre then
        content.md.preface = pre:read('*a')
    end
end

content.md.body = ''
do
    for i, n in ipairs(md_files) do
        local bd, err = io.open(n)
        if not bd then
            print('error opening file: '..n)
            print(err)
            os.exit(-2)
        end
        content.md.body = content.md.body..bd:read('*a')
    end
end

-- define the engine
local pass_seq = {'md', 'md2latex', 'latex', 'latex2pdf'}
local passes = {md = {}, md2latex = {}, latex = {}, latex2pdf = {}}
Pass = function (desc)
    if not passes[desc.phase] then
        print('warning: unkown phase '..desc.phase..' in '..desc.name)
        passes[desc.phase] = {}
    end
    verbose_log('insert '..desc.name..' to phase '..desc.phase)
    table.insert(passes[desc.phase], desc)
end

-- gether the datas
passes_dir = 'passes/'
if io.open(passes_dir..'/patch.lua') then
    dofile(passes_dir..'/patch.lua')
end
passes_dir = prog_dir..'/passes/'
if io.open(passes_dir..'/patch.lua') then
    dofile(passes_dir..'/patch.lua')
end
dofile(passes_dir..'/trans.lua')

-- Go
for _, step in ipairs(pass_seq) do
    print('do step '..step)
    for _, p in ipairs(passes[step]) do
        print('processing "'..p.part..'" with "'..p.name..'"')
        content[p.nphase or p.phase][p.part] =
              p.proc(content[p.pphase or p.phase][p.part])
    end
end
