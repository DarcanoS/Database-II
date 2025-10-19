#!/bin/bash
pdflatex -shell-escape Paper.tex

mkdir -p ../../docs/Paper
mv Paper.pdf ../../docs/Paper/Paper.pdf