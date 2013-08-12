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
