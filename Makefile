# This makefile converts a set of files in a source directory to various
# output formats using pandoc.
#
# ASSUMPTIONS:
# - Files to convert live in a directory called `chapters`
# - The abstract lives in a directory called `extras` and contains the
#   word "abstract" somewhere in its name
# - Front matter lives in a directory called `extras` a contain a
#   keyword in their name to help identify the file
#   (keywords: copyright, dedication, acknowledgment)
# - Appendices live in a directory called `extras` and contain
#   the word "appendix" somewhere in their name
#   word "abstract" somewhere in its name
# - Pandoc templates exist in a directory called `templates`
#
# This file is provided without warranty, but has been tested on MacOS
# to produce a viable thesis formatted according to the Vanderbilt
# University Graduate School style guidelines.

PANDOC = pandoc

# Default values, may be overridden with command line arguments
# Ex: make abstract ABSTRACT_DIR=abstract
SOURCE_DIR ?= chapters
ABSTRACT_DIR ?= extras
FRONTMATTER_DIR ?= extras
BACKMATTER_DIR ?= extras
GRAPHICS_DIR ?= figures
TEMPLATE_DIR ?= templates
SETTINGS_DIR ?= extras
BIB_DIR ?= extras
CSL_DIR ?= extras
CSS_DIR ?= extras/css
JS_DIR ?= extras/js
FILE_NAME ?= thesis

# Files we want to find dynamically
SETTINGS := $(wildcard $(SETTINGS_DIR)/*.yml $(SETTINGS_DIR)/*.yaml)
CHAPTERS := $(wildcard $(SOURCE_DIR)/*)
ABSTRACT := $(wildcard $(ABSTRACT_DIR)/*abstract*)
COPYRIGHT := $(wildcard $(FRONTMATTER_DIR)/*copyright*)
DEDICATION := $(wildcard $(FRONTMATTER_DIR)/*dedication*)
ACKNOWLEDGMENTS := $(wildcard $(FRONTMATTER_DIR)/*acknowledgment*)
NOMENCLATURE := $(wildcard $(FRONTMATTER_DIR)/*nomenclature*)
APPENDICES := $(wildcard $(BACKMATTER_DIR)/*appendix*)
TEMPLATES := $(wildcard $(TEMPLATE_DIR)/*)
BIBLIOGRAPHY := $(wildcard $(BIB_DIR)/*.bib)
CSL := $(wildcard $(CSL_DIR)/*.csl)
CSS := $(wildcard $(CSS_DIR)/*.css)
JS := $(wildcard $(JS_DIR)/*)

# Detect appropriate run-time options
ifneq ('$(BIBLIOGRAPHY)','')
BIB_OPTIONS += --bibliography=$(BIBLIOGRAPHY)
endif
ifneq ('$(CSL)','')
BIB_OPTIONS += --csl=$(CSL)
endif
BEFORE = _tmp/title.tex
ifneq ('$(COPYRIGHT)','')
SETTINGS_EXTRAS += --metadata=copyright:true
FRONTMATTER += $(COPYRIGHT)
BEFORE += _tmp/copyright.tex
endif
ifneq ('$(DEDICATION)','')
SETTINGS_EXTRAS += --metadata=dedication:true
FRONTMATTER += $(DEDICATION)
BEFORE += _tmp/dedication.tex
endif
ifneq ('$(ACKNOWLEDGMENTS)','')
SETTINGS_EXTRAS += --metadata=acknowledgments:true
FRONTMATTER += $(ACKNOWLEDGMENTS)
BEFORE += _tmp/acknowledgments.tex
endif
ifneq ('$(NOMENCLATURE)','')
SETTINGS_EXTRAS += --metadata=nomenclature:true
FRONTMATTER += $(NOMENCLATURE)
BEFORE += _tmp/nomenclature.tex
endif
ifneq ('$(APPENDICES)','')
SETTINGS_EXTRAS += --metadata=appendix:true
BACKMATTER += $(APPENDICES)
AFTER += _tmp/appendix.tex
endif

# Files we can build on demand
THESIS_TARGET := _build/pandoc/$(FILE_NAME).pdf
THESIS_ABSTRACT := _build/pandoc/$(FILE_NAME)_abstract.pdf
THESIS_TITLE := _build/pandoc/title_signatures.pdf
LATEX_TARGET := _build/latex/$(FILE_NAME).pdf
LATEX_ABSTRACT := _build/latex/$(FILE_NAME)_abstract.pdf
OVERLEAF_TARGET := _build/overleaf/$(FILE_NAME).pdf
DOC_TARGET := _build/doc/$(FILE_NAME).docx
PDF_TARGETS := $(patsubst $(SOURCE_DIR)/%,_build/pdf/%.pdf,$(basename $(CHAPTERS)))
DRAFT_TARGETS := $(patsubst $(SOURCE_DIR)/%,_build/draft/%.pdf,$(basename $(CHAPTERS)))
HTML_TARGETS := $(patsubst $(SOURCE_DIR)/%,_build/html/%.html,$(basename $(CHAPTERS)))
DOC_TARGETS := $(patsubst $(SOURCE_DIR)/%,_build/doc/%.docx,$(basename $(CHAPTERS)))
DRAFT_SETTINGS_TARGETS := $(patsubst $(SETTINGS_DIR)/%,_tmp/%,$(SETTINGS))

# Settings
USER_OPTIONS = $(foreach file, $(SETTINGS),--metadata-file=$(file))
GENERAL_OPTIONS = --metadata-file=templates/settings_default.yaml $(BIB_OPTIONS) $(USER_OPTIONS) 
REQUIRED_OPTIONS = --metadata-file=templates/settings_required.yaml
COMMON_OPTIONS = $(GENERAL_OPTIONS) $(SETTINGS_EXTRAS) $(REQUIRED_OPTIONS)
OVERLEAF_OPTIONS = $(COMMON_OPTIONS) --template=templates/overleaf.tex --natbib
PANDOC_OPTIONS = $(COMMON_OPTIONS) --resource-path=$(GRAPHICS_DIR) -F pandoc-crossref --citeproc
PDF_OPTIONS = $(PANDOC_OPTIONS) --pdf-engine=xelatex --template=templates/pandoc.tex
HTML_OPTIONS = $(PANDOC_OPTIONS) \
				--standalone \
				--embed-resources \
				--mathjax \
				$(foreach style, $(CSS),--css=$(style)) \
				$(foreach injection, $(JS),-H $(injection))
DOC_OPTIONS = $(PANDOC_OPTIONS)
SIMPLIFY = --metadata=toc:false --metadata=lot:false --metadata=lof:false \
				--metadata=title:"" --metadata=subtitle:"" --metadata=author:"" --metadata=date:"" \
				--metadata=numbersections:false --quiet
DRAFT = $(SIMPLIFY) --metadata-file=_tmp/draft.yaml
ABSTRACT_OPTIONS = $(GENERAL_OPTIONS) --template=templates/abstract.tex
THESIS_OPTIONS = $(foreach file, $(BEFORE),-B $(file)) \
				$(foreach file, $(AFTER),-A $(file)) \
				$(PDF_OPTIONS)
LATEX_OPTIONS = $(foreach file, $(BEFORE),-B $(file)) \
				$(foreach file, $(AFTER),-A $(file)) \
				$(COMMON_OPTIONS) \
				--template=templates/pandoc.tex --natbib

# Files we want to trigger a rebuild if updated
PANDOC_REQUIRES = $(TEMPLATE_DIR)/settings_default.yaml \
				$(SETTINGS) \
				$(TEMPLATE_DIR)/settings_required.yaml
THESIS_REQUIRES = $(PANDOC_REQUIRES) \
				$(TEMPLATE_DIR)/sfchap.sty \
				$(TEMPLATE_DIR)/sfsection.sty
TITLE_OPTIONS = $(COMMON_OPTIONS) $(SIMPLIFY) \
				--metadata=classoption:oneside \
				--pdf-engine=xelatex

all: clean thesis pdf html doc

# TARGETS get expanded to a list of files; any file that doesn't yet
# exist in this list gets built according to the recipe for the target
thesis: $(THESIS_TARGET) $(THESIS_ABSTRACT) $(THESIS_TITLE)
title: $(THESIS_TITLE)
abstract: $(LATEX_ABSTRACT)
latex: $(LATEX_TARGET)
overleaf: $(OVERLEAF_TARGET)
pdf: $(PDF_TARGETS) 
html: $(HTML_TARGETS)
doc: $(DOC_TARGET)
docs: $(DOC_TARGETS)
draft: $(DRAFT_TARGETS) 

clean:
	rm -rf _build

purge:
	rm -rf _build _tmp

# Make the above recipes behave like commands in case any files happen
# to share the name of the coresponding make target
.PHONY: all thesis abstract latex overleaf pdf draft html doc clean purge

# Recipes for complete targets via pandoc

$(THESIS_TARGET): $(CHAPTERS) $(BEFORE) $(AFTER) $(THESIS_REQUIRES) | _build/pandoc
	@echo "Building $@ from $(CHAPTERS)"
	@$(PANDOC) -o $@ $(THESIS_OPTIONS) $(CHAPTERS)

$(THESIS_ABSTRACT): $(ABSTRACT) $(PANDOC_REQUIRES) templates/abstract.tex | _build/pandoc
	@echo "Building $@ from $<"
	@$(PANDOC) -o $@ $(ABSTRACT_OPTIONS) $<

$(THESIS_TITLE): _tmp/title_signatures.tex $(PANDOC_REQUIRES) | _build/pandoc
	@echo "Building $@ from settings and $<"
	@$(PANDOC) -o $@ $(TITLE_OPTIONS) -B $< /dev/null

# Recipes for explicit builds

$(LATEX_TARGET): _tmp/pandoc.tex $(THESIS_REQUIRES) | _build/latex
	@echo "Compiling $< to _tmp/pandoc.pdf"
	@pdflatex -interaction=nonstopmode --shell-escape --output-directory=_tmp $< &> /dev/null
	@echo "Running bibtex"
	@TEXMFOUTPUT="_tmp:" BIBINPUTS="$(BIB_DIR):" BSTINPUTS="$(BIB_DIR):" bibtex _tmp/pandoc &> /dev/null
	@echo "Updating references in _tmp/pandoc.pdf"
	@pdflatex -interaction=nonstopmode --shell-escape --output-directory=_tmp $< &> /dev/null
	@pdflatex -interaction=nonstopmode --shell-escape --output-directory=_tmp $< &> /dev/null
	mv _tmp/pandoc.pdf $@

$(LATEX_ABSTRACT): _tmp/abstract.tex | _build/latex
	@echo "Compiling $< to _tmp/pandoc.pdf"
	@pdflatex -interaction=nonstopmode --output-directory=_tmp $< &> /dev/null
	mv _tmp/abstract.pdf $@

$(OVERLEAF_TARGET): _tmp/overleaf.tex $(BEFORE) $(AFTER) | _build/overleaf
	@echo "Compiling $< to _tmp/overleaf.pdf"
	@pdflatex -interaction=nonstopmode --shell-escape --output-directory=_tmp $< &> /dev/null
	@echo "Running bibtex"
	@TEXMFOUTPUT="_tmp:" BIBINPUTS="$(BIB_DIR):" BSTINPUTS="$(BIB_DIR):" bibtex _tmp/overleaf &> /dev/null
	@echo "Updating references in _tmp/overleaf.pdf"
	@pdflatex -interaction=nonstopmode --shell-escape --output-directory=_tmp $< &> /dev/null
	@pdflatex -interaction=nonstopmode --shell-escape --output-directory=_tmp $< &> /dev/null
	mv _tmp/overleaf.pdf $@

$(DOC_TARGET): $(CHAPTERS) $(BEFORE) $(AFTER) $(THESIS_REQUIRES) | _build/doc
	@echo "Building $@ from $(CHAPTERS)"
	@$(PANDOC) -o $@ $(DOC_OPTIONS) $(CHAPTERS)

# Recipes to build single files

_build _tmp:
	@mkdir $@

_build/pdf _build/draft _build/html _build/doc _build/pandoc _build/latex _build/overleaf: | _build
	@mkdir $@

_build/pdf/%.pdf: $(SOURCE_DIR)/%.* $(PANDOC_REQUIRES) templates/pandoc.tex | _build/pdf
	@echo "Building $@ from $<"
	@$(PANDOC) -o $@ $(PDF_OPTIONS) $(SIMPLIFY) $<

_build/draft/%.pdf: $(SOURCE_DIR)/%.* $(PANDOC_REQUIRES) templates/pandoc.tex _tmp/draft.yaml | _build/draft
	@echo "Building $@ from $<"
	@$(PANDOC) -o $@ $(PDF_OPTIONS) $(DRAFT) $<

_build/html/%.html: $(SOURCE_DIR)/%.* $(CSS) $(JS) $(PANDOC_REQUIRES) | _build/html
	@echo "Building $@ from $<"
	@$(PANDOC) -o $@ $(HTML_OPTIONS) $(SIMPLIFY) $<

_build/doc/%.docx: $(SOURCE_DIR)/%.* $(PANDOC_REQUIRES) | _build/doc
	@echo "Building $@ from $<"
	@$(PANDOC) -o $@ $(DOC_OPTIONS) $(SIMPLIFY) $<

# Recipes to build required dependencies

_tmp/%.yaml: extras/%.yaml templates/draft.yaml | _tmp
	@echo "Building $@ from $<"
	@sed "/header-includes:/r templates/draft.yaml" $< > $@

_tmp/%.yml: extras/%.yml templates/draft.yaml | _tmp
	@echo "Building $@ from $<"
	@sed "/header-includes:/r templates/draft.yaml" $< > $@

_tmp/draft.yaml: $(DRAFT_SETTINGS_TARGETS) | _tmp
	@echo "Building $@ from $(DRAFT_SETTINGS_TARGETS)"
	@cat $(DRAFT_SETTINGS_TARGETS) > $@

_tmp/title.tex: $(PANDOC_REQUIRES) templates/title.tex | _tmp
	@echo "Building $@ from settings and templates/$(@F)"
	@$(PANDOC) -o $@ -f markdown --template=templates/$(@F) $(PANDOC_OPTIONS) /dev/null

_tmp/title_signatures.tex: $(PANDOC_REQUIRES) templates/title_signatures.tex | _tmp
	@echo "Building $@ from settings and templates/$(@F)"
	@$(PANDOC) -o $@ -f markdown -s --template=templates/title_signatures.tex $(COMMON_OPTIONS) /dev/null

_tmp/copyright.tex: $(COPYRIGHT) $(PANDOC_REQUIRES) templates/copyright.tex | _tmp
	@echo "Building $@ from $<"
	@$(PANDOC) -o $@ --template=templates/$(@F) $(PANDOC_OPTIONS) $<

_tmp/dedication.tex: $(DEDICATION) $(PANDOC_REQUIRES) templates/dedication.tex | _tmp
	@echo "Building $@ from $<"
	@$(PANDOC) -o $@ --template=templates/$(@F) $(PANDOC_OPTIONS) $<

_tmp/acknowledgments.tex: $(ACKNOWLEDGMENTS) $(PANDOC_REQUIRES) templates/acknowledgments.tex | _tmp
	@echo "Building $@ from $<"
	@$(PANDOC) -o $@ --template=templates/$(@F) $(PANDOC_OPTIONS) $<

_tmp/appendix.tex: $(APPENDICES) $(PANDOC_REQUIRES) | _tmp
	@echo "Building $@ from $(APPENDICES)"
	@$(PANDOC) -o $@ $(PANDOC_OPTIONS) $(APPENDICES)

_tmp/abstract.tex: $(ABSTRACT) $(PANDOC_REQUIRES) templates/abstract.tex | _tmp
	@echo "Building $@ from $<"
	@$(PANDOC) -o $@ $(ABSTRACT_OPTIONS) $<

_tmp/pandoc.tex: $(CHAPTERS) $(SETTINGS) $(BEFORE) $(AFTER) $(PANDOC_REQUIRES) templates/pandoc.tex | _tmp
	@echo "Building $@ from templates/$(@F) and $(SETTINGS)"
	@$(PANDOC) -o $@ $(LATEX_OPTIONS) $(CHAPTERS)
	@echo "Adjusting location of sfchap in $@ to point to templates/"
	@mv $@ $@.tmp && sed 's/templates\/sfchap/\.\.\/templates\/sfchap/g' < $@.tmp > $@
	@echo "Adjusting location of sfsection in $@ to point to templates/"
	@mv $@ $@.tmp && sed 's/templates\/sfsection/\.\.\/templates\/sfsection/g' < $@.tmp > $@
	@echo "Adjusting figure directory in $@ to $(GRAPHICS_DIR)/"
	@mv $@ $@.tmp && awk '1;/templates\/sfsection/{print "\\graphicspath{{../$(GRAPHICS_DIR)}}"}' < $@.tmp > $@
	@mv $@ $@.tmp && awk '1;/\\usepackage{svg}/{print "\\svgpath{$(GRAPHICS_DIR)/}"}' < $@.tmp > $@
	@mv $@ $@.tmp && sed 's/\\usepackage{svg}/\\usepackage[inkscapepath=_tmp]{svg}/' < $@.tmp > $@
	@rm $@.tmp

_tmp/overleaf.tex: $(CHAPTERS) $(SETTINGS) $(PANDOC_REQUIRES) templates/overleaf.tex | _tmp
	@echo "Building $@ from $(SETTINGS) and $(SETTINGS_EXTRAS)"
	@$(PANDOC) -o $@ $(OVERLEAF_OPTIONS) $(CHAPTERS)
	@echo "Adjusting location of sfchap in $@ to point to templates/"
	@mv $@ $@.tmp && sed 's/sfchap/\.\.\/templates\/sfchap/g' < $@.tmp > $@
	@echo "Adjusting location of sfsection in $@ to point to templates/"
	@mv $@ $@.tmp && sed 's/sfsection/\.\.\/templates\/sfsection/g' < $@.tmp > $@
	@echo "Adjusting input paths in $@ to point to _tmp/"
	@mv $@ $@.tmp && sed 's/\\input{\(.*\)}/\\input{_tmp\/\1}/g' < $@.tmp > $@
	@echo "Adjusting figure directory in $@ to $(GRAPHICS_DIR)/"
	@mv $@ $@.tmp && sed 's/\\graphicspath{{\(.*\)}}/\\graphicspath{{\.\.\/$(GRAPHICS_DIR)}}/g' < $@.tmp > $@
	@mv $@ $@.tmp && awk '1;/\\usepackage{svg}/{print "\\svgpath{$(GRAPHICS_DIR)/}"}' < $@.tmp > $@
	@mv $@ $@.tmp && sed 's/\\usepackage{svg}/\\usepackage[inkscapepath=_tmp]{svg}/' < $@.tmp > $@
	@rm $@.tmp
