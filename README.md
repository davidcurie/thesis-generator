# A thesis generator for Vanderbilt University

This repository provides an automated mechanism to generate all parts of
a thesis for submission to the Vanderbilt University Graduate School. It also
provides a means to generate draft documents of individual chapters in
a variety of formats for distribution to reviewers.

## Why

Despite how powerful and elegant LaTeX is, writing a thesis as a series of
`.tex` documents is cumbersome. Online tools like Overleaf simplify this
tremendously and provide useful features like collaborative editing. Vanderbilt
University even provides an [official Overleaf template][Vanderbilt-overleaf]
for writing graduate theses. These approaches still require you to write in
pure LaTeX syntax.

Pandoc allows you to convert many document types to LaTeX. This means you can
write in any format you want, using any editor you want, and convert your
document to LaTeX syntax for professional typesetting. Additionally, Pandoc
seamlessly handles the conversion of many image types, so if you include images
files in your source documents in `.svg` format, Pandoc will automatically
convert them to `.png`.

Applying special thesis formatting to files generated by Pandoc is possible,
but often requires many command-line options. Wrapping these `pandoc`
incantations in a single makefile allows for pain-free generation of target
files simply by using `make <target>` instead.

See the available [commands](#commands) below.

[Vanderbilt-overleaf]: https://www.overleaf.com/latex/templates/vanderbilt-university-dissertation-template/fmqpcfjqtgyq

## Requirements

- [Make](https://www.gnu.org/software/make/)
- [Pandoc](https://pandoc.org/index.html)
- [LaTeX distribution](https://www.latex-project.org)

### Required files to edit

- Content in the `chapters/` directory
- An abstract in the `extras/` directory
- A YAML metadata file in the `extras/` directory with some required fields

> While the `make` recipes in this project should work on any standard input
> file, writing the source files in Pandoc markdown format allows for more
> seamless conversion to other output formats, like EPUB or HTML, which are more
> tablet-friendly formats.

Chapters are written in the `chapters/` directory and will be included in
name-sorted order, which means you can control the inserted order by using file
names `01-intro` and `02-experiment`.

The title page for the printed thesis is generated automatically from a fixed
template and relevant title words are extracted from user-defined metadata. In
particular, this project makes use of the following assumed metadata fields:

```yaml
title: "A title"
author: First Last
institution: Some University
degree: Doctor of Philosopy
major: Major
date: Month Day, Year
location: City, State
chair:
    name: First Last
    title: Ph.D.
committee:
  - name: First Last
    title: Ph.D.
  - name: First Last
    title: Ph.D.
  - name: First Last
    title: Ph.D.
  - name: First Last # Repeat only as necessary
    title: Ph.D.
```

### Extras

Bibliographies, additional user-defined metadata, and target-specific styling
parameters belong in the `extras/` directory.

The `extras/` directory is explicitly aware of a few file types and file names
(case-insensitive) during the Make process.

- Any file with the word `abstract` in the file name will be recognized as
  contents to be included in the required abstract. This file is expected to be
  content only; no special section markers are necessary, but stylized text is
  allowed.
- Any file with the words `copyright`, `dedication`, or `acknowledgment` in
  the file name will be automatically detected as front matter and included in
  the appropriate order during a full build.
- Any and all files with the words `appendix` in the file name will be
  automatically detected as an appendix entry and included in the name-sorted
  order after the bibliography. Each appendix should include its own top-level
  section header.
- Any and all files with `.yaml` or `.yml` extension will be treated as Pandoc
  metadata options and will be passed into Pandoc with the `--metadata-file`
  flag in name-sorted order.
- Any `.bib` file in the `extras/` directory will be automatically used by
  Pandoc during each of the build operations. Specifically, Pandoc will use the
  `--citeproc` filter to convert generalized Pandoc citations to
  target-specific syntax (i.e. `\cite{}` for LaTeX, `<div class=csl-entry>` for
  HTML).
- Any `.csl` file placed in the `extras/` directory will be automatically
  applied to the bibliography when using Pandoc
- Any and all `.css` file placed in the `extras/css/` directory will be applied
  to the HTML build process.
- Any and all files placed in the `extras/js` directory will be inserted verbatim
  into the header of each HTML file using the `--header-includes` Pandoc
  option.

In addition to the required fields outlined in the previous section that _must_
be specified, users can extend their preferences with additional Pandoc
metadata fields.

The following snippet placed into any YAML file adds a subtitle to the title
page, adjusts the line spacing of the main content with `linestretch`, adjusts
the settings to the LaTeX geometry package, and specifies some extra packages
and tweaks to be inserted in the preamble of a LaTeX document.

```yaml
subtitle: "An optional subtitle"
linestretch: 1.5
geometry:
  - layout=letterpaper
  - top=1in
  - bottom=1in
  - inner=1.5in
  - outer=1in
  - heightrounded
header-includes:
  - \usepackage{parskip}
  - \setlength{\parindent}{20pt}
  - \def\thechapter{\arabic{chapter}}
```

## Getting started

After cloning, forking, or downloading this repository to your preferred
location, your publishing process can be as simple as:

1. Create and edit the required files described above.

2. Open a terminal at the root of this cloned project.

```bash
cd path/to/thesis/
```

3. Generate your desired target

```bash
make thesis
```

### Updating

The templates in this repository may need to be updated from time to time,
either because of clarifications in the official Overleaf template provided by
the Vanderbilt University Graduate School, or because future versions of Pandoc
introduce newer features that are incompatible with existing templates.

#### Re-download

If you don't track your changes in Git, you can delete and re-download or
re-clone this repository.

Make a copy of your `extras/` and `chapters/` folders, re-download this entire
repository, and place your `extras/` and `chapters/` folders in the fresh
project.

#### Git pull

If you cloned this repository, navigate to this repository in a terminal that
has access to Git and run the following:

```bash
git pull
```

or the more verbose \[equivalent\] command:

```bash
git pull origin main
```

#### GitHub sync fork

If you forked this repository to your own GitHub account so that you could
track your own changes in Git, update your upstream reference with one of the
two methods below:

- Under the `Code` drop-down menu at the top of the repository on GitHub,
  select "Sync fork".

OR

- In your local terminal, run the following commands:

```bash
git fetch upstream
git merge upstream/main
```

> `git merge` can equivalently be replaced by `git rebase` if you have
a preference on your own local integration strategy.

## How it works

The `templates/` directory contains various Pandoc templates, Pandoc settings,
and LaTeX styles that are used to generate preconfigured LaTeX files necessary
for a complete build. These templates strive to follow published guidelines set
forth by the Vanderbilt University Graduate School and do not need to be
modified.

The `_tmp/` directory holds pre-compiled LaTeX pages for front matter that has
non-standard styling, such as the title page. If not present, this directory
will be created and populated at runtime. The construction of its files is
determined by the template files and from contents in the user-controlled
`extras/` directory. After a build is complete, the files in `_tmp/` may be
safely discarded; they will be generated again if needed.

During the build process, the intermediate contents of the `_tmp/` directory
and the source files in the `chapters/` and `extras/` directory are converted
and assembled with Pandoc all at once. The final output depends on the
arguments supplied to `make`, but all final files will end up in some subfolder
of a `_build/` directory. If not present, this directory will be created after
a `make <target>` command.

In general, `make <target>` will build a target directly from the intermediate
files. If the intermediate file responsible for the build does not yet exist,
it will be created from the source documents. The makefile knows about the
dependencies of intermediate files it creates, so if a change occurs to the
source file responsible for generating an intermediate file, the intermediate
file will first be updated before the target is rebuilt.

This project supplies some required options and safe defaults as metadata
options stored in the `templates/` directory. These are combined with the user
options defined in the `extras/` directory. In the case where competing
metadata entries are present across several additional files, the value from
the last-loaded file persists.

The makefile detects and loads metadata in the following order: `DEFAULTS`,
`USER`, `REQUIRED`. This order ensures users cannot accidentally override
strictly required styles. If multiple user metadata files are detected, they
are loaded in name-sorted order.

Due to the way dictionary merges are handled in Pandoc, metadata fields like
`geometry:` or `header-includes:` that accept an array of sub-options are
completely replaced by the presence of a new entry in a later file. This means
that partially supplied fields from multiple documents do not stack, even if
the subfields within that entry do not conflict.

See Pandoc's notes on [yaml metadata blocks][yaml-blocks] for more details.

[yaml-blocks]: https://pandoc.org/MANUAL.html#extension-yaml_metadata_block

## Commands

### Syntax

```bash
make <target>
```

where `<target>` is replaced by several options below.

### Generate a thesis

Generate a fully compiled thesis (title, optional front matter if present, main
content, bibliography, optional appendix if present) and a separate abstract
page formatted for submission to print.

```bash
make thesis
```

The results are stored under `_build/pandoc/thesis.pdf` and
`_build/pandoc/thesis_abstract.pdf`.

### Generate review documents

If you wish to share copies of your source documents with your reviewers, you
can convert each source document to a target format specified below. The file
names of each source document will be preserved in the output target.

Make a PDF of each chapter:

```bash
make pdf
```

## File maintenance

Generate a thesis, abstract, and a review document of each chapter in all
target formats:

```bash
make all
```

Remove all target build files:

```bash
make clean
```

Removing all build files will trigger a rebuild of any target from the contents
in the `_tmp/` directory on the next invocation of `make`.

Remove all target build files and intermediate files:

```bash
make purge
```

