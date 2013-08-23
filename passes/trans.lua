local pandoc_opts = "--latex-engine xelatex --chapters --toc --number-sections -V usectex:1"
local pandoc_fmt  = "markdown+header_attributes+fenced_code_blocks+escaped_line_breaks"

local cmd = 'pandoc -f '..pandoc_fmt..' -o _preface.tex '..pandoc_opts

local proc_file = function (cmd, ofile)
    return function (str)
        if not str then
            local f, err = io.open(ofile, 'w')
            if not f then
                print('open "'..ofile..'" error: '..err)
                os.exit(-1)
            end
            return str
        end
        -- there are difficulties to get bidirectional communication right
        -- Actually, we need to write the files eventually.
        local f, err = io.popen(cmd, 'w')
        if not f then
            print('popen "'..cmd..'" error: '..err)
            os.exit(-1)
        end
        local res, err = f:write(str)
        if not res then
            print('write to popen error: '..err)
            os.exit(-1)
        end
        f:close()
        local f, err = io.open(ofile)
        if not f then
            print('open "'..ofile..'" error: '..err)
            os.exit(-1)
        end
        return f:read('*a')
    end
end

local proc_preface_md = proc_file(cmd, '_preface.tex')

Pass{
    name = 'translate preface',
    part = 'preface',
    proc = proc_preface_md,
    pphase = 'md',
    phase = 'md2latex',
    nphase = 'latex',
}

cmd = 'pandoc --template '..prog_dir..'/default.latex'..' -f '..
       pandoc_fmt..' -o _body.tex '..pandoc_opts..' -B _preface.tex'

local proc_body_md = proc_file(cmd, '_body.tex')

Pass{
    name = 'translate body',
    part = 'body',
    proc = proc_body_md,
    pphase = 'md',
    phase = 'md2latex',
    nphase = 'latex',
}

local proc_body_md = function (str)
    if not str then
        print('no output LaTeX')
        os.exit(-4)
    end
    local f, err = io.open(out_name..'.tex', 'w')
    if not f then
        print('open "'..out_name..'.tex" error: '..err)
        os.exit(-1)
    end
    f:write(str)
    f:close()

    local cmd = 'xelatex '..out_name
    local st, reason, code = os.execute(cmd)
    if not st then
        print('error executing "'..cmd..'"('..code..'): '..reason)
        os.exit(code)
    end
    local st, reason, code = os.execute(cmd)
    if not st then
        print('error executing "'..cmd..'"('..code..'): '..reason)
        os.exit(code)
    end

    os.exit()
end

Pass{
    name = 'translate body',
    part = 'body',
    proc = proc_body_md,
    pphase = 'latex',
    phase = 'latex2pdf',
    --nphase = 'pdf',
}
