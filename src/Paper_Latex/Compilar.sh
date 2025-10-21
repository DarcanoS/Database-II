#!/bin/bash

# Primera compilación para generar archivos auxiliares
pdflatex -interaction=nonstopmode -shell-escape Paper.tex

# Segunda compilación para procesar las referencias
pdflatex -interaction=nonstopmode -shell-escape Paper.tex

# Tercera compilación para asegurar que todo esté correcto
pdflatex -interaction=nonstopmode -shell-escape Paper.tex

# Crear directorio de destino y mover el PDF
mkdir -p ../../docs/Paper
cp Paper.pdf ../../Catch-Up/Paper.pdf

echo "Compilación completada. PDF generado en docs/Paper/Paper.pdf"