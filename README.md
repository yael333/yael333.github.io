# README


## Introduction

cl-yag is a lightweight, static site generator that produces
**gopher** sites as well as **html** websites.  The name 'cl-yag'
stands for 'Common Lisp - Yet Another website Generator'.  It runs
without needing Quicklisp (Common LISP library manager).


## Showcase

I am using cl-yag to create and maintain my websites in the
world-wide-web (visit: *[Solene's percent]
(https://dataswamp.org/~solene/)*) as well as [in gopher-space]
(gopher://dataswamp.org/1/~solene/).


## Requirements

To use cl-yag you'll need:

1. A Common Lisp Interpreter
    - cl-yag's current default is [Steel Bank Common Lisp (SBCL)](http://www.sbcl.org/).
    - [Embeddable Common Lisp (ECL)](https://common-lisp.net/project/ecl/) will do fine as well.
2. A Markdown-to-HTML Converter
    - cl-yag's current default is [multimarkdown](http://fletcherpenney.net/multimarkdown/).


## Usage

Go into your project's directory and type ``make``. You'll find your new website/gopher page in **output/**.  
If you want to get rid of everything in your **output/** sub directories, type ``make clean``.  
For further commands: read the Makefile.
Read in the following section where to find it.


## Overview: cl-yag's File Hierarchy

After cloning the repository, your project's directory should contain at
least the following files and folders:

	.
	|-- LICENSE
	|-- Makefile
	|-- README.md
	|-- data/
	|   |-- 1.md
	|   |-- README.md
	|   `-- articles.lisp
	|-- generator.lisp
	|-- output/
	|   |-- gopher/
	|   `-- html/
	|-- static/
	|   |-- css/style.css
	|   `-- img/
	`-- templates/
		|-- article.tpl
		|-- gopher_head.tpl
		|-- layout.tpl
		|-- one-tag.tpl
		|-- rss-item.tpl
		`-- rss.tpl

- **Makefile**
    - This file exists to simplify the recurring execution of frequently used commands.
- **generator.lisp**
    - This is cl-yag's core library.
- **static/**
    - This directory holds content, that needs to be published without being changed (e.g. style sheets, js-scripts).
	- If you come from 'non-static CMS'-Country: **static/** holds, what you would put in your **assets/** directory.
- **templates/**
    - The templates in this directory provide the structural skeleton(s) of the web pages and feeds you want to create.
- **output/**
    - cl-yag puts in this directory everything ready to get deployed.
	- Because cl-yag generates not only HTML, but gopher-compliant pages as well, **output/** **holds two sub directories**.
		- **gopher/** contains the website for gopher,
		- **html/** contains the website in HTML.

And there is the **data/** directory, which is important enough to get a subsubsection of its own.

### The data/ Directory

This directory is crucial for the usage of cl-yag.

**data/** contains

- the **articles.lisp** configuration file, which defines important meta-data for posts and pages.
- It also holds **${id}.md** files, which are holding your posts' (or pages') content. You can use markdown to write them.

For more information: Read section 'Configuration'.


## Configuration

cl-yag's main configuration file is **data/articles.lisp**.  
In order to have a running implementation of cl-yag, you have
to set most of the values in this file.

**data/articles.lisp** has two parts:

1. A variable called *config*. Its values define your web page.
2. "posts" declaration with their meta-data

Values are assigned by placing a string (e.g. ``"foo"``) or a boolean
(i.e. ``t`` or ``nil``) behind a keyword (e.g. ``:title``).


### The *config* Variable

The *config* variable is used to assign the following values:

- **:webmaster**
    - The name of the default(!) author. 
	- ``:webmaster`` gets used, if ``:author`` is omitted. (See below: 'The **articles** variable'.)
- **:title**
    - The title of the web-page
- **:description**
    - This text is used in the *description* field of the atom/rss feed.
- **:url**
    - This needs to be the full(!) URL of your website, including(!) a final slash.
	- MIND: If the url contains a tilde (~), it needs to get duplicated.
	- Example: ``https://mydomain/~~user/``
- **:rss-item-number**
    - This holds the number of latest(!) RSS items you want to get published.
- **html**
    - ``t`` to export html website. Set ``nil`` to disable.
- **gopher**
    - ``t`` to export gopher website. Set ``nil`` to disable.
- **gopher-path**
    - This is the full path of the directory to access your gopher hole.
- **gopher-server**
    - Hostname of the gopher server. It needs to be included in each link.
- **gopher-port**
    - tcp port of the gopher server. 70 is the default port. It needs to be included in each link.
- **gopher-format**
    - format of the gopher server. default is the geomyidae format, gophernicus format is commented.
- **gopher-index**
    - name of the gopher menu file. default is index.gph for geomyidae, gophermap file is commented.


### Posts declarations

Each post is declared with its meta-data using the function "post".
So you need to add a new line for each of your posts.

Of the following keywords, only ``:author`` and ``:short`` can be omitted.

- **:author**
    - The ``:author`` field is used to display the article's author.
    - If you omit it, the generator will take the name from the ``:webmaster`` field of the *config* variable.
- **:id**
    - The ``:id`` field holds the file name of your post/page.
	- Example: ``:id "2"`` will load file **data/2.md**. Use text instead of numbers, if you want to.
	- (See section: 'The **data/** Directory'.)
- **:tag**
    - ``:tag`` field is used to create a "view" containing all articles of the same tag.
	-  MIND: White spaces are used to separate tags and are not allowed in(!) tags.
- **:tiny**
	- The ``:tiny`` field's value is used for displaying a really short description of the posts content on your homepage.
	- If ``:tiny`` doesn't get a value, the full article gets displayed.
	- Hint: Use ``:tiny "Read the full article for more information."``, if you don't want to display the full text of an article on your index site.
- **:title**
	- The ``:title`` field's value sets your post's title, its first headline, as well as its entry on the index.html.


## How-to Create A New Post
 
Edit **data/articles.lisp** and add a new list to the *articles* variable:

    (list :title "How do I use cl-yag" 
		  :id "2"
		  :date "29 April 2016" 
		  :author "Solène"
		  :tiny "Read more about how I use cl-yag." 
		  :tag "example help code")

Then write a corresponding **data/2.md** file, using markdown.


## How-to Publish A Post

I prepared a Makefile to facilitate the process of generating and
publishing your static sites.
All you need to do in order to publish is to go into your cl-yag
directory and type ``make``.

The make command creates html and gopher files in the defined location.
The default is the **output/** directory, but you can use a symbolic link
pointing to some other directory as well.


## How-to Add A New Page

You may want to have some dedicated pages besides the index or a post.
To create one, edit the *generate-site* function in cl-yag's
**generator.lisp** and add a function call, like this:

    (generate "somepage.html" (load-file "data/mypage.html"))
  
This will produce **output/html/somepage.html**.


## Further Customization

### How-to Use Another Common Lisp Interpreter

cl-yags default Lisp interpreter is **sbcl**. If you want to use a
different interpreter you need to set the variable *LISP* to the name
of your binary, when calling ``make``:

    make LISP=ecl


### Using git Hooks For Publishing

You may customize your publishing-process further, e.g. by using a git
hook to call the make program after each change in the repo so your
website gets updated automatically.


## Page-Includes

Here is an example code, if you want to include another page in the template:

1. Create **templates/panel.tpl** containing the html you want to include.
2. Add a replacement-string in the target file, where the replacement should occur.  
   In this case, we choose **%%Panel%%** for a string, and, because we want the panel to be displayed on each page, we add this string to **templates/layout.tpl**.

3. Modify the function *generate-layout* in cl-yag's **generator.lisp** accordingly.  
   This is done by adding the following template function call:

		(template "%%Panel%%" (load-file "templates/panel.tpl"))

Another valid approach is to writer your html directly into **templates/layout.tpl**.

## Known Limitations

### Use ~~ To Create ~

cl-yag crashes if you use a single "~" character inside
**templates/articles.lisp**, because Common Lisp employs the tilde as a
prefix to indicate format specifiers in format strings.

In order to use a literal `~` -- e.g. for creating a ``:title`` or
``:url`` reference -- you have to *escape* the tilde *by
duplicating* it: ``~~``.  (See ``:url`` in section 'Configuration').


### Posting Without Tagging

cl-yag allows posts without tags, but, using the default
**templates/layout.tpl**, you'll get a line below your title that
displays: "Tags: ".

(Note: If you are looking for a way to contribute this may be a task for you.)


### A Note On Themes

Although cl-yag may ship with a minimalist template, cl-yag focuses
on generating html- and gopher-compliant structural markup - not
themed layouts.

If you want some deeply refined, cross-browser compatible, responsive,
webscale style sheets, you need to create them yourself.  However,
cl-yag will work nicely with them and if you want to make your
style sheets a part of cl-yag you're very welcome to contact me.


# Hacking cl-yag

I tried to make cl-yag easy to extend.  
If you want to contribute, feel free to contact me and/or to send in a patch.

- If you are looking for a way to contribute:
    - You could find a way to "sanitize" cl-yag's behaviour regarding the tilde (see: above);
    - Also see: 'Note' in 'Posting Without Tagging';
	- Also see: 'A Note On Themes'.
