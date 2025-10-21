#!/bin/bash

# Primera compilación para generar archivos auxiliares
pdflatex -interaction=nonstopmode -shell-escape CS_report_template.tex

# Compilar bibliografía
bibtex CS_report_template

# Segunda compilación para procesar las referencias
pdflatex -interaction=nonstopmode -shell-escape CS_report_template.tex

# Tercera compilación para asegurar que todo esté correcto
pdflatex -interaction=nonstopmode -shell-escape CS_report_template.tex

# Crear directorio de destino y mover el PDF
cp CS_report_template.pdf ../../Catch-Up/Report.pdf

echo "Compilación completada. PDF generado en Catch-Up/Report.pdf"
