#!/bin/bash
# Limpia archivos temporales de compilación en Poster_Latex

EXTS=(aux bbl bcf fdb_latexmk fls log out run.xml toc synctex.gz blg lof lot)

for ext in "${EXTS[@]}"; do
    find . -type f -name "*.$ext" -delete
    find ./images -type f -name "*.$ext" -delete 2>/dev/null
done

echo "Archivos temporales eliminados en Poster_Latex."
