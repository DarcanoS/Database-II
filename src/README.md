# Source Code - LaTeX Documents

This directory contains the LaTeX source code for all project deliverables. Each subdirectory includes compilation and cleaning scripts for convenient document generation.

## Directory Structure

### 📄 Paper_Latex
Contains the source code for the academic paper following IEEE format.

**Files included:**
- `Paper.tex` - Main paper document
- `references.tex` - Bibliography references
- `Sections/` - Individual paper sections (abstract, introduction, methods, results, conclusions)
- `Pictures/` - Images and figures used in the paper

### 📊 Poster_Latex
Contains the source code for the academic poster presentation.

**Files included:**
- `Poster.tex` - Main poster document
- `images/` - Images and graphics for the poster

### 📖 Report_Latex
Contains the source code for the comprehensive project report.

**Files included:**
- `Report.tex` - Main report document
- `references.bib` - Bibliography in BibTeX format
- `glossaries.tex` - Glossary definitions
- `chapters/` - Individual report chapters (abstract, introduction, methodology, results, etc.)
- `figures/` - Images and figures used in the report

### 🛠️ Workshop_Latex
Contains the source code for workshop documentation and code examples.

**Files included:**
- `Workshop.tex` - Main workshop document
- `references.bib` - Bibliography in BibTeX format
- `Secciones/` - Workshop sections
- `Codigos/` - Code examples
- `Imagenes/` - Images and diagrams

## Compilation Scripts

Each subdirectory includes two Bash scripts for Linux environments:

### `Compilar.sh` - Compilation Script
Compiles the LaTeX document to generate the final PDF.

**Usage (Linux/macOS):**
```bash
cd <subdirectory>
./Compilar.sh
```

**For Windows users:**
- Install a LaTeX distribution (e.g., MiKTeX or TeX Live)
- Use a LaTeX editor like TeXstudio, Overleaf, or VS Code with LaTeX Workshop extension
- Open the main `.tex` file and compile using the editor's built-in compilation feature
- Alternatively, use the command line with: `pdflatex <filename>.tex`

### `clean_temp.sh` - Cleaning Script
Removes temporary files generated during compilation (`.aux`, `.log`, `.fls`, etc.).

**Usage (Linux/macOS):**
```bash
cd <subdirectory>
./clean_temp.sh
```

**For Windows users:**
- Manually delete temporary files, or
- Use a batch script to delete common LaTeX temporary files:
  ```batch
  del *.aux *.log *.out *.toc *.fls *.fdb_latexmk *.synctex.gz
  ```

## Requirements

To compile these documents, you need:

- **LaTeX Distribution:**
  - Linux: TeX Live (`sudo apt install texlive-full`)
  - macOS: MacTeX
  - Windows: MiKTeX or TeX Live

- **Additional Packages:**
  - IEEE templates (for Paper)
  - baposter class (for Poster)
  - minted package (for code highlighting in Workshop)
  - BibTeX/Biber (for bibliography management)

## Notes

- Make sure scripts have execution permissions on Linux/macOS: `chmod +x *.sh`
- Some documents may require multiple compilation passes for proper reference resolution
- The Workshop document uses `minted` for code highlighting, which requires Python and Pygments installed

---

For more information about the project, see the [main README](../README.md).
