SCLVER := $(shell awk '/ProvidesPackage\{subcaptionlite\}/{getline; sub(/^ *\[/, ""); print $$2}' subcaptionlite.sty)

DOCS := subcaptionlite.pdf

.PHONY: ctanzip
ctanzip: subcaptionlite.zip ## Archive for CTAN upload
subcaptionlite.zip: clean $(DOCS)
	git archive --format=tar --prefix=subcaptionlite/ HEAD | gtar -x
	## remove unpacked files
	cd subcaptionlite/ && \
		rm -f .gitignore Makefile ctan.toml
	## then, now just make archive
	zip -9 -r subcaptionlite.zip subcaptionlite/*
	rm -rf subcaptionlite
	@echo finished

.PHONY: subcaptionlite.pdf
subcaptionlite.pdf: subcaptionlite.tex subcaptionlite.sty
	pdflatex -interaction=nonstopmode -halt-on-error $<
	pdflatex -interaction=nonstopmode -halt-on-error $<

## Run the test suite ($(SCLVER)):
##  * every test compiles without errors or warnings (run twice, for
##    the references)
##  * SCL-RESULT OK and no SCL-* NG: the labels, references, counters,
##    widths and anchors are as expected (see test-common.tex)
##  * test-hyperref-*: no warning on a duplicate or missing destination
##    in the log or in the output of the engine and (x)dvipdfmx
##  * test-errors-*: the expected error message
## A test is "<engine>:<jobname>:<input>".  The output of the engine and
## of (x)dvipdfmx is kept in <jobname>.term.
TESTS := \
  pdflatex:test-basic-pdflatex:'\input test-basic' \
  xelatex:test-basic-xelatex:'\input test-basic' \
  lualatex:test-basic-lualatex:'\input test-basic' \
  lualatex:test-basic-ltjsarticle-lualatex:'\def\CLS{ltjsarticle}\input test-basic' \
  platex:test-basic-platex:'\def\CLS{jarticle}\input test-basic' \
  uplatex:test-basic-uplatex:'\def\CLS{ujarticle}\input test-basic' \
  pdflatex:test-hyperref-pdflatex:'\input test-hyperref' \
  pdflatex:test-hyperref-first-pdflatex:'\def\SCLhyperfirst{}\input test-hyperref' \
  xelatex:test-hyperref-xelatex:'\input test-hyperref' \
  lualatex:test-hyperref-lualatex:'\input test-hyperref' \
  platex:test-hyperref-platex:'\def\CLS{jarticle}\input test-hyperref' \
  uplatex:test-hyperref-uplatex:'\def\CLS{ujarticle}\input test-hyperref' \
  lualatex:test-japanese-lualatex:'\input test-japanese' \
  lualatex:test-japanese-late-lualatex:'\def\SCLlatejapanese{}\input test-japanese' \
  platex:test-japanese-platex:'\def\CLS{jsarticle}\input test-japanese' \
  uplatex:test-japanese-uplatex:'\def\CLS{ujarticle}\input test-japanese'

## "<case>:<error message>" of test-errors.tex (pdflatex)
ERRORS := \
  outside:"subcaption outside float" \
  type:"has no subcaptions"

.PHONY: test
test:
	@set -e; \
	for t in $(TESTS); do \
	  eng=$${t%%:*}; rest=$${t#*:}; job=$${rest%%:*}; in=$${rest#*:}; \
	  echo "== $$eng $$job"; \
	  rm -f $$job.aux $$job.dvi $$job.xdv; \
	  opt=; if [ $$eng = xelatex ]; then opt=-no-pdf; fi; \
	  $$eng $$opt -interaction=nonstopmode -jobname=$$job "$$in" >/dev/null 2>&1 || true; \
	  $$eng $$opt -interaction=nonstopmode -jobname=$$job "$$in" >$$job.term 2>&1 || true; \
	  if [ -f $$job.dvi ]; then dvipdfmx $$job.dvi >>$$job.term 2>&1; fi; \
	  if [ -f $$job.xdv ]; then xdvipdfmx $$job.xdv >>$$job.term 2>&1; fi; \
	  if grep -q '^!' $$job.log; then echo "NG: error in $$job.log"; exit 1; fi; \
	  if grep -q '^SCL-.* NG' $$job.log; then grep '^SCL-.* NG' $$job.log; exit 1; fi; \
	  grep -q '^SCL-RESULT OK' $$job.log || \
	    { echo "NG: no SCL-RESULT OK in $$job.log"; exit 1; }; \
	  if grep '^\(LaTeX\|Package\|Class\) .*Warning' $$job.log; then \
	    echo "NG: warning in $$job.log"; exit 1; fi; \
	  case $$job in test-hyperref-*) \
	    if cat $$job.log $$job.term | \
	      grep -i 'duplicate\|already defined\|does not exist\|unreferenced destination'; then \
	      echo "NG: destination warning in $$job.log or $$job.term"; exit 1; fi;; \
	  esac; \
	done; \
	for e in $(ERRORS); do \
	  c=$${e%%:*}; msg=$${e#*:}; job=test-errors-$$c; \
	  echo "== pdflatex $$job"; \
	  pdflatex -interaction=nonstopmode -jobname=$$job "\def\CASE{$$c}\input test-errors" >$$job.term 2>&1 || true; \
	  grep -q "^! Package subcaptionlite Error: .*$$msg" $$job.log || \
	    { echo "NG: no expected error in $$job.log"; exit 1; }; \
	done; \
	echo "All tests passed ($(SCLVER))"

.PHONY: clean
clean: ## Clean this repository
	rm -rf subcaptionlite.zip subcaptionlite
	rm -f *.aux *.log *.out *.toc *.dvi *.xdv *.synctex.gz *.term
	rm -f test-*.pdf
	find . -type f -name "*~" -delete
