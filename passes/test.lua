local echo = function (x)
    return function (str)
        print(string.format('--- echo%s ---', x))
        print(str)
        print(string.format('--- echo%s ---', x))
        return str
    end
end

Pass{
    name = 'echo',
    phase = 'md',
    part = 'preface',
    proc = echo('markdown preface'),
}

Pass{
    name = 'echo',
    phase = 'md',
    part = 'body',
    proc = echo('markdown body'),
}

Pass{
    name = 'echo',
    phase = 'latex',
    part = 'preface',
    proc = echo('latex preface'),
}

Pass{
    name = 'echo',
    phase = 'latex',
    part = 'body',
    proc = echo('latex body'),
}
