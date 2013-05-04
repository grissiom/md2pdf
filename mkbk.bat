ECHO off

:: get the path where this script is located in
for %%F in ("%0") do set dirname=%%~dpF
SET pandoc_opts=--latex-engine xelatex --chapters --toc --number-sections
SET pandoc_fmt=markdown+header_attributes+fenced_code_blocks
SET out_f=%1
SHIFT

IF "%out_f%"=="" (
        ECHO no output file name
        GOTO :eof
)

SET md_f=
:Loop
IF "%1"=="" GOTO Continue
SET md_f=%md_f% %1
SHIFT
GOTO Loop
:Continue

IF NOT "%md_f%"=="" GOTO Ok2
ECHO no markdown file name
GOTO :eof
:Ok2

ECHO 'generating' %out_f%

DEL %out_f%.aux %out_f%.out %out_f%.log %out_f%.toc

IF EXIST preface.md (
        pandoc -f %pandoc_fmt% -o _preface.tex %pandoc_opts% preface.md
        SET md_f=-B _preface.tex %md_f%
)

pandoc --template %dirname%\default.latex -f %pandoc_fmt% -o %out_f%.tex %pandoc_opts% %md_f%
xelatex %out_f%.tex
xelatex %out_f%.tex

ECHO %out_f% 'generated'
