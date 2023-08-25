# General markup syntax

This example file illustrates how one can compose a document
using Pandoc markdown syntax. Markdown is a lightweight syntax with limited
styling options that emphasizes content over form. The simplified and
semi-rigorous syntax rules make it efficient to parse and reformat into other
language styles--most notably HTML. Pandoc markdown is a superset of strict
markdown that has additional support for common typeset elements present in
other popular target formats. Pandoc supports many language styles within the
same document, so any manual formatting tweaks not directly accessible with
markdown syntax can usually be achieved by using the target language syntax
directly in the markdown document. This means you can write sections of your
document in HTML or LaTeX when you really need it.

Be mindful that the more you hard-code your syntax to a particular language,
the less flexible the conversion process becomes when you target other media.
HTML tags give you great flexibility in styling your blog posts, but they lose
their meaning if you decide to publish that blog post as a print article.
Likewise for LaTeX, formatting tables in your markdown document with
LaTeX syntax might leave some features behind if you eventually publish your
thesis as an e-book.

## Citations

If you have a BibTeX bibliography file with accessible citation references, you
can include them in your Pandoc file in several ways. Here is a citation using
pandoc notation[@curie_correlative_2022]. Here is a citation using \LaTeX\
notation\cite{curie_correlative_2022}. If you use Pandoc with the `--citeproc`
command line flag, both of these references should show up. If you use the
`--natbib` command line flag, the Pandoc reference notation will not convert
references properly and you'll need to use other tools to search and replace
all occurrences of Pandoc notation to \LaTeX notation.

## Figures

The following snippet illustrates how you can insert a figure in Pandoc syntax.
Note that the basic syntax will automatically assign the word `Figure X`, where
`X` is the ordered number of appearance in the document. This number is
cumulative across all figures in a single document, even if compiled through
Pandoc through multiple input files.

![This is the alt text property, used as a figure caption and title in PDF](thesis_motivation.svg "This is a figure title for aria-accessibility"){width=100%}

Notice how the figure is on its own line. Note that paragraphs are demarcated
by a newline both above and below the figure. If a figure appears in the middle
of a paragraph or at the end of a paragraph without a new line, it will be
rendered as an in-line image, like this:
![This is an inline image](google_G_logo.svg)
Notice that text is wrapped around this image differently depending on the
target format. In print format, this image has no figure caption.

## Horizontal rules

Horizontal rules are generated whenever the source document contains 3 or more
sequential hyphens (`-`) on their own line. The following sequence illustrates
a horizontal rule.

------------------------------------------------------------------------

Here is another horizontal rule using the minimum syntax required by markdown.

---

There should be a horizontal rule above this text.

## Footnotes

Footnotes are created in markdown by writing `[^*]` at the place you wish to
link your footnote. The contents of `*` in the bracket can be a number or
a word. The body of the footnote can then be defined elsewhere by using `[^*]:
body` later in the document.

Here's a simple footnote,[^1] and here's a longer one.[^2]

[^1]: This is the first footnote.

[^2]: Here's one with multiple paragraphs and code.

    Indent paragraphs to include them in the footnote.
 
    `{ my code }`

    Add as many paragraphs as you like


## Stylized text

### Native pandoc

_Italic_ text is created by surrounding a word with a single underscore (`_`) or
asterisk (`*`).
**Bold** text is created by surrounding a word with double underscores (`__`) or
asterisks (`**`).
`Monospace` text is created by surrounding a word with backticks (\`).
You can make any text super^script^ by surrounding it with carets (`^`).
You can make any text sub~script~ by surrounding it with tildes (`~`).

Links are created with the one of following syntaxes:

- `[link name](link-reference)`
- `<link-reference>`

Here is a [link with a long title](https://www.google.com).

Here is another link by raw reference: <https://www.google.com>

See if your Pandoc version supports the automatic conversion of shorthand
symbols like -> or <-. These may only be rendered properly for print media.

### Raw HTML 

Pandoc accepts raw HTML formatting. These formatting tweaks do not apply to PDF
output by default. If you have appropriate styles defined for CSS fields in
your rendered HTML document, you can stylize your text in customizable ways.
This project supplies some basic CSS rules that are automatically applied to
HTML documents generated by Pandoc with the following command.

```bash
make html
```

Text that is surrounded in the `<del>` tag will appear like <del>strikethrough/delete</del> text.
Text that is surrounded in the `<ins>` tag will appear like <ins>inserted</ins> text.
Text that is surrounded in the `<mark>` tag will appear like <mark>highlighted</mark> text.
Text that is surrounded in the `<kbd>` tag will appear like <kbd>CTRL</kbd> keyboard text.

### Raw LaTeX

This paragraph demonstrates some Pandoc syntax intertwined with \LaTeX syntax.
Note that the LaTeX command eats up the space following the command. You can
increase the space by following it with a backslash (\). 

This is how inline math $i\int$ re$n$de$r^e_d$

Here is a multi-line math equation surrounded by double dollar signs (`$$`):

$$
f(t) = \frac{1}{2}at^2 + v_0t + x_0
F ({\tau}, \alpha) = \| \mathrm{dev}[{\tau}] \| - \sqrt{\frac{2}{3}} \left[ \sigma_Y + K\alpha \right] \le 0
$$

### Lists and blocks

This is an unordered list:

-   Item
-   Item
    -   Nested item
        -   Doubly nested item
-   Item

Here is an ordered list with mixed styles:

1.  First
2.  Second
    a.  This should be item 2a.
3.  Third
    i.  This should be item 3i.

This is a task list:

- [x] Edit this document
- [ ] Save document
- [ ] Use Pandoc to generate .html
- [ ] Open generated file in browser
    - [ ] Here is another TODO item

### Definitions

Definition Term
:   Actual definition

Definition Term
:   Actual definition


### Block quotes

> Here is a block quote. Use this to make a quote stand out in the page.
> It should be indented and have a darkened background.
>
> > This is a nested block quote.
>
> -- Author

### Code

```html
<h1>My Awesome Header</h1>
<img src='images/Fig1.svg' alt='Some figure' />
```

```css
html {
    font-size: 100%;
    overflow-y: scroll;
    -webkit-text-size-adjust: 100%;
    -ms-text-size-adjust: 100%;
}
```

```json
{
  "firstName": "John",
  "lastName": "Smith",
  "age": 25
}
```


        This is supposed to be code since
        it is indented by two tabs


This is a sentence with `monospace font`, which is suitable for inline code.

### Tables


| Syntax      | Description | Test Text     |
| :---        |    :----:   |          ---: |
| Header      | Title       | Here's this   |
| Paragraph   | Text        | And more      |
: A table caption

