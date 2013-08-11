--[[ lfs = require"lfs" --]]

prog_name = 'mkbk.lua'
prog_dir  = string.gsub(arg[0], prog_name..'$', '')
help = string.format(
'Useage: %s output_file_name md_files', prog_dir..prog_name)
table.remove(arg, 0)

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
    if os.getenv('VERBOSE') then
        print('clean '..name)
    end
    os.remove(name)
end

local verbose_log = function (str)
    if os.getenv('VERBOSE') then
        print(str)
    end
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
    for i, n in ipairs(arg) do
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
        print('warning: unkown phase '..desc.phase..', create one')
        passes[desc.phase] = {}
    end
    verbose_log('insert '..desc.name..' to '..desc.phase)
    table.insert(passes[desc.phase], desc)
end

-- gether the datas
passes_dir = prog_dir..'passes/'

--dofile(passes_dir..'test.lua')
dofile(passes_dir..'trans.lua')

for _, step in ipairs(pass_seq) do
    print('do step '..step)
    for _, p in ipairs(passes[step]) do
        verbose_log('processing "'..p.part..'" with "'..p.name..'"')
        content[p.nphase or p.phase][p.part] =
              p.proc(content[p.pphase or p.phase][p.part])
    end
end
