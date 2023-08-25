This is the acknowledgment section. Notice how there is no explicit section
heading in this source file. This is because Pandoc doesn't have an easy way to
convert section headings to unnumbered chapters. We get around this limitation
by introducing a custom Pandoc template for this page in
`templates/acknowledgments.tex` where we define the structure of the page. The
contents of this file are inserted into the latex template with the `$body$`
parameter.

The Makefile for this project detects if an acknowledgment file is present in
the `extras/` directory. If none is detected, a blank `acknowledgments.tex`
file is placed in the `_tmp/` directory because the `pandoc.tex` template
depends on such a file being present.

Here is more text to fill out a page with more depth so you can see that the
acknowledgments section is produced with `\singeline` spacing as defined in the
`thesis.tex` template.

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod
tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At
vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd
gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
