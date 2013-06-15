#!/bin/bash

# get the path where this script is located in
prog_dir=$(dirname $0)
pandoc_opts="--latex-engine xelatex --chapters --toc --number-sections"
pandoc_fmt="markdown+header_attributes+fenced_code_blocks"
out_f=$1
shift 1
md_f=$*

if [[ x"$out_f" = x"" || x"$md_f" = x"" ]]; then
    echo "Useage:" $0 output_file_name md_files
    exit 255
fi

echo 'generating' $out_f

rm $out_f.aux $out_f.out $out_f.log $out_f.toc 2>/dev/null

if [ -f preface.md ]; then
    pandoc -f $pandoc_fmt -o _preface.tex $pandoc_opts preface.md
    md_f="-B _preface.tex $md_f"
fi

pandoc --template $prog_dir/default.latex -f $pandoc_fmt -o $out_f.tex $pandoc_opts $md_f && \
xelatex $out_f.tex && \
xelatex $out_f.tex && \
echo $out_f 'generated'
