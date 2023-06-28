LISP=sbcl

all: dirs html

html: $(HTML) css
	$(LISP) --load generator.lisp

dirs:
	mkdir -p "output/html/static"
	mkdir -p "output/gopher"
	mkdir -p "output/gemini/articles/"


clean:
	rm -fr output/html/* output/gopher/* output/gemini/* "temp"

css:
	mkdir -p "output/html/static"
	cp -fr static/* "output/html/static/"
	mkdir -p "output/html/resources"
	cp -fr resources/* "output/html/resources/"
