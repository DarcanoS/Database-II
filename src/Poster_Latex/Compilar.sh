#!/bin/bash

# Primera compilación para generar archivos auxiliares
pdflatex -interaction=nonstopmode -shell-escape Poster.tex

# Segunda compilación para procesar las referencias
pdflatex -interaction=nonstopmode -shell-escape Poster.tex

# Tercera compilación para asegurar que todo esté correcto
pdflatex -interaction=nonstopmode -shell-escape Poster.tex

# Crear directorio de destino y mover el PDF
cp Poster.pdf ../../Catch-Up/Poster.pdf

echo "Compilación completada. PDF generado en Catch-Up/Poster.pdf"
