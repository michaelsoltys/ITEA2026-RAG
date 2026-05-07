# Makefile to build the RAG paper
#
# Usage:
#   make          # build PDF (only when sources changed)
#   make all      # force rebuild of PDF (ignores timestamps)
#   make rag      # build RAG PDF
#   make clean    # remove all LaTeX auxiliary files (keeps PDFs)
#   make cleanall # remove all generated files including PDFs
#
# Requirements: xelatex, biber (for biblatex)

MAIN := rag.tex
BASE := $(patsubst %.tex,%,$(MAIN))
PDF := $(BASE).pdf
SRC := $(wildcard *.tex) $(wildcard *.bib) $(wildcard *.sty) $(wildcard *.cls)

.PHONY: all rag clean cleanall force

# Always use xelatex + biber (not latexmk)
BIBER := $(shell command -v biber 2>/dev/null)

# Default target: build only if sources changed
default: $(PDF)

# Force rebuild of PDF regardless of timestamps
all:
	@echo "=== Force rebuilding PDF ==="
	@$(MAKE) --always-make $(PDF)
	@echo "=== PDF rebuilt successfully ==="

# Build RAG paper
$(PDF): $(SRC)
	@echo "Building $@ from $(MAIN)"
	@xelatex -interaction=nonstopmode $(MAIN)
	@if [ -n "$(BIBER)" ]; then \
		biber $(BASE); \
	else \
		echo "Error: biber not found. Install biber (required for biblatex)."; exit 1; \
	fi
	@xelatex -interaction=nonstopmode $(MAIN)
	@xelatex -interaction=nonstopmode $(MAIN)
	@echo "Successfully built $@"

rag: $(PDF)

# Clean all LaTeX auxiliary files (keeps PDFs)
clean:
	@echo "Removing LaTeX auxiliary files (keeping PDFs)"
	@rm -f *.aux *.log *.out *.toc *.lof *.lot \
	       *.bbl *.blg *.bcf *.run.xml *-blx.bib \
	       *.fls *.fdb_latexmk *.synctex.gz *.nav *.snm \
	       *.vrb *.dvi *.ps *.idx *.ind *.ilg \
	       *.glo *.gls *.glg *.xdy *.tdo 2>/dev/null || true
	@echo "Clean complete. PDFs preserved."

# Clean everything including PDFs (for complete rebuild)
cleanall:
	@echo "Removing all generated files including PDFs"
	@rm -f *.aux *.log *.out *.toc *.lof *.lot \
	       *.bbl *.blg *.bcf *.run.xml *-blx.bib \
	       *.fls *.fdb_latexmk *.synctex.gz *.nav *.snm \
	       *.vrb *.dvi *.ps *.idx *.ind *.ilg \
	       *.glo *.gls *.glg *.xdy *.tdo \
	       *.pdf 2>/dev/null || true
	@echo "Complete clean finished. All generated files removed."
