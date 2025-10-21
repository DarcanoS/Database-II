#!/bin/bash

# Primera compilación para generar archivos auxiliares
pdflatex -interaction=nonstopmode -shell-escape Report.tex

# Compilar bibliografía
bibtex Report

# Segunda compilación para procesar las referencias
pdflatex -interaction=nonstopmode -shell-escape Report.tex

# Tercera compilación para asegurar que todo esté correcto
pdflatex -interaction=nonstopmode -shell-escape Report.tex

# Crear directorio de destino y mover el PDF
cp Report.pdf ../../Catch-Up/Report.pdf

echo "Compilación completada. PDF generado en Catch-Up/Report.pdf"
