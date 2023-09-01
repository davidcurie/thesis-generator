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
EXT ?= .md
FILE_NAME ?= thesis

# Files we want to find dynamically
SETTINGS := $(shell find $(SETTINGS_DIR) -type f \( -iname '*.yaml' -or -iname '*.yml' \)| sort)
CHAPTERS := $(shell find $(SOURCE_DIR) -type f -iname '*$(EXT)' | sort)
ABSTRACT := $(shell find $(ABSTRACT_DIR) -type f -iname '*abstract*$(EXT)')
COPYRIGHT := $(shell find $(FRONTMATTER_DIR) -type f -iname '*copyright*$(EXT)')
DEDICATION := $(shell find $(FRONTMATTER_DIR) -type f -iname '*dedication*$(EXT)')
ACKNOWLEDGMENTS := $(shell find $(FRONTMATTER_DIR) -type f -iname '*acknowledgment*$(EXT)')
NOMENCLATURE := $(shell find $(FRONTMATTER_DIR) -type f -iname '*nomenclature*')
APPENDICES := $(shell find $(BACKMATTER_DIR) -type f -iname '*appendix*$(EXT)'| sort)
TEMPLATES := $(shell find $(TEMPLATE_DIR) -type f -name '*')
BIBLIOGRAPHY := $(shell find $(BIB_DIR) -maxdepth 1 -type f -iname '*.bib')
CSL := $(shell find $(CSL_DIR) -maxdepth 1 -type f -iname '*.csl')

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

# Settings
USER_OPTIONS = $(foreach file, $(SETTINGS),--metadata-file=$(file))
GENERAL_OPTIONS = --metadata-file=templates/settings_default.yaml $(BIB_OPTIONS) $(USER_OPTIONS) 
REQUIRED_OPTIONS = --metadata-file=templates/settings_required.yaml
COMMON_OPTIONS = $(GENERAL_OPTIONS) $(SETTINGS_EXTRAS) $(REQUIRED_OPTIONS)
PANDOC_OPTIONS = $(COMMON_OPTIONS) --resource-path=$(GRAPHICS_DIR) --citeproc
PDF_OPTIONS = $(PANDOC_OPTIONS) --pdf-engine=xelatex --template=templates/pandoc.tex
ABSTRACT_OPTIONS = $(GENERAL_OPTIONS) --template=templates/abstract.tex
THESIS_OPTIONS = $(foreach file, $(BEFORE),-B $(file)) \
				$(foreach file, $(AFTER),-A $(file)) \
				$(PDF_OPTIONS)

# Files we want to trigger a rebuild if updated
PANDOC_REQUIRES = $(TEMPLATE_DIR)/settings_default.yaml \
				$(SETTINGS) \
				$(TEMPLATE_DIR)/settings_required.yaml
THESIS_REQUIRES = $(PANDOC_REQUIRES) \
				$(TEMPLATE_DIR)/sfchap.sty \
				$(TEMPLATE_DIR)/sfsection.sty

all: clean thesis

# TARGETS get expanded to a list of files; any file that doesn't yet
# exist in this list gets built according to the recipe for the target
thesis: $(THESIS_TARGET) $(THESIS_ABSTRACT)

clean:
	rm -rf _build

purge:
	rm -rf _build _tmp

# Make the above recipes behave like commands in case any files happen
# to share the name of the coresponding make target
.PHONY: all thesis clean purge

# Recipes for complete targets via pandoc

$(THESIS_TARGET): $(CHAPTERS) $(BEFORE) $(AFTER) $(THESIS_REQUIRES)
	@mkdir -p $(@D)
	@echo "Building $@ from $(CHAPTERS)"
	@$(PANDOC) -o $@ $(THESIS_OPTIONS) $(CHAPTERS)

$(THESIS_ABSTRACT): $(ABSTRACT) $(PANDOC_REQUIRES) templates/abstract.tex
	@mkdir -p $(@D)
	@echo "Building $@ from $<"
	@$(PANDOC) -o $@ $(ABSTRACT_OPTIONS) $<

# Recipes to build required dependencies

_tmp/title.tex: $(PANDOC_REQUIRES) templates/title.tex
	@mkdir -p $(@D)
	@echo "Building $@ from settings and templates/$(@F)"
	@$(PANDOC) -o $@ -f markdown --template=templates/$(@F) $(PANDOC_OPTIONS) /dev/null

_tmp/copyright.tex: $(COPYRIGHT) $(PANDOC_REQUIRES) templates/copyright.tex
	@mkdir -p $(@D)
	@echo "Building $@ from $<"
	@$(PANDOC) -o $@ --template=templates/$(@F) $(PANDOC_OPTIONS) $<

_tmp/dedication.tex: $(DEDICATION) $(PANDOC_REQUIRES) templates/dedication.tex
	@mkdir -p $(@D)
	@echo "Building $@ from $<"
	@$(PANDOC) -o $@ --template=templates/$(@F) $(PANDOC_OPTIONS) $<

_tmp/acknowledgments.tex: $(ACKNOWLEDGMENTS) $(PANDOC_REQUIRES) templates/acknowledgments.tex
	@mkdir -p $(@D)
	@echo "Building $@ from $<"
	@$(PANDOC) -o $@ --template=templates/$(@F) $(PANDOC_OPTIONS) $<

_tmp/appendix.tex: $(APPENDICES) $(PANDOC_REQUIRES)
	@mkdir -p $(@D)
	@echo "Building $@ from $(APPENDICES)"
	@$(PANDOC) -o $@ $(PANDOC_OPTIONS) $(APPENDICES)
