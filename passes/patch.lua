Pass{
    name = 'fix latex figure',
    phase = 'latex',
    part = 'body',
    proc = function (input)
	input = string.gsub(input,
	                    '\\begin{figure}%[htbp%]',
			    '\\begin{figure}[htb]')
	return input
    end
}

Pass{
    name = 'add shade to Shaded env',
    phase = 'latex',
    part = 'body',
    proc = function (input)
	input = string.gsub(input,
	                    '\\newenvironment{Shaded}{}{}',
			    '\\newenvironment{Shaded}{\\begin{snugshade}}{\\end{snugshade}}')
	return input
    end
}

Pass{
    name = 'add latex figure label',
    phase = 'md',
    part = 'body',
    proc = function (input)
        st = {}
        for line in string.gmatch(input, '[^\r\n]*') do
            if #line == 0 then
                table.insert(st, '\n')
            else
                name, other = string.match(line, '!%[(.*)%](.*)')
                if name then
                    table.insert(st, '!['..name..'\\label{fg:'..name..'}]'..other)
                else
                    table.insert(st, line)
                end
            end
        end
        return table.concat(st, '')
    end
}
