# subcaptionlite Package

**LaTeX: Subfigures and subcaptions without the caption package**

The subcaption package needs the caption package, which redefines `\@makecaption` of the class. Thus it cannot be used with a class that has its own design of captions.

The subcaptionlite package provides the `subfigure` environment, `\subcaption` and `\subcaptionbox` without touching `\@makecaption` of the class:

1. Subfigures are numbered (a), (b), ... within each figure, and `\ref` gives e.g. `4.2(a)` (`\Cref` of cleveref: "Figure 4.2(a)"). With hyperref, each subfigure has its own anchor.
2. The figure number of the subfigures is right whether the `\caption` of the figure comes after the subcaptions (the first subcaption steps the figure counter in advance, as the subcaption package does) or before them.
3. `\captionsetup` is accepted and ignored, so that the settings for the caption package can be left in the document.

* **Supported formats/engines:** pdfLaTeX, XeLaTeX, LuaLaTeX (with or without LuaTeX-ja), pLaTeX, upLaTeX (+ dvipdfmx)

## Files

| File | Description |
|---|---|
| `subcaptionlite.sty` | The package |
| `subcaptionlite.tex` / `.pdf` | Documentation |
| `test-*.tex` | Test suite (see below) |

## Requirements

* LaTeX2e 2020-10-01 or later, `etoolbox`
* Tested with TeX Live 2026 (LaTeX2e 2026-06-01, hyperref 7.01s)

## Installation

Copy `subcaptionlite.sty` to your local TeX tree:
`$TEXMF/tex/latex/subcaptionlite/`

## Usage

```latex
\usepackage{subcaptionlite}

\begin{figure}
  \centering
  \begin{subfigure}{.45\linewidth}
    \centering\includegraphics[width=\linewidth]{a}
    \caption{The first}\label{fig:a}   % \caption means \subcaption here
  \end{subfigure}\hfill
  \subcaptionbox{The second\label{fig:b}}[.45\linewidth]{%
    \includegraphics[width=.8\linewidth]{b}}
  \caption{Two subfigures}\label{fig:ab}
\end{figure}
```

* `\begin{subfigure}[<pos>]{<width>}`: a minipage, inside which `\caption` and `\caption*` mean `\subcaption` and `\subcaption*`.
* `\subcaption{<text>}`, `\subcaption*{<text>}`: a numbered/unnumbered subcaption, e.g. in a minipage.
* `\subcaptionbox{<caption>}[<width>]{<contents>}`: `<contents>` centered in a minipage of `<width>` (default: the natural width of `<contents>`), followed by `\subcaption{<caption>}`. The minipage keeps `<width>` even if `<contents>` is wider.

## Customization

Redefine these macros in the class or in a local style (`\makeatletter` is needed in the preamble):

| Macro | Default |
|---|---|
| `\subcaption@font` | `\small` |
| `\subcaption@sep` (between the label and the text) | `\hspace{.5zw}` with pTeX, `.5\zw` with LuaTeX-ja (or a class that defines `\zw`), `.5em` otherwise |
| `\subcaption@skip` (between the subfigure and its subcaption) | `\vskip.25\baselineskip` |

The label is `\thesubfigure` (default: `(\alph{subfigure})`).

## Limitations

* Subcaptions are for figures only: there is no subtable.
* subcaptionlite cannot be used together with the caption or subcaption package.

## Testing

`make test` compiles every test twice with pdfLaTeX, XeLaTeX, LuaLaTeX, pLaTeX and upLaTeX (+ dvipdfmx), and checks the log:

* `SCL-RESULT OK`: every label (`\@currentlabel`), reference, counter, width and anchor checked in the test is as expected (see `test-common.tex`), and `\@makecaption` of the class is unchanged.
* No error and no LaTeX/package/class warning.
* `test-hyperref`: no warning on a duplicate or missing destination in the log or in the output of the engine and (x)dvipdfmx.

| Test | Engines | What it covers |
|---|---|---|
| `test-basic.tex` | pdflatex, xelatex, lualatex (article, ltjsarticle), platex, uplatex | `subfigure`, `\subcaption`/`\subcaption*`, `\subcaptionbox` (with/without width, wider contents), the caption of the figure below/above the subfigures or none, `figure*`, `\ref`, `\captionsetup`, the class's `\@makecaption`, the label separator |
| `test-hyperref.tex` | pdflatex (hyperref loaded after and before the package), xelatex, lualatex, platex, uplatex | `test-basic.tex` with hyperref and cleveref: anchors, the `\cref` type, no duplicate destinations |
| `test-japanese.tex` | lualatex (ltjsarticle; article with LuaTeX-ja loaded after the package), platex (jsarticle), uplatex (ujarticle) | a Japanese document, the label separator `.5zw` |

`test-common.tex` holds the helpers shared by the tests.

## Repository

* <https://github.com/munepi/subcaptionlite>
* Bug reports: <https://github.com/munepi/subcaptionlite/issues>

## License

This package is licensed under the conditions of the [LaTeX Project Public License](https://www.latex-project.org/lppl.txt), either version 1.3c of this license or any later version.

Copyright (c) 2026 Munehiro Yamamoto
