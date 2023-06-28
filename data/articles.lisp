;; MIND: The tilde character "~" must be escaped like this '~~' to use it as a literal.


;; Define Your Webpage

(defvar *config*
  (list
   :webmaster       "Yael"
   :title           "ᛟYael"
   :description     "Yael's Digital Grimoire"
   :url             "https://anti.moe/~~yael"        ;; the trailing slash is mandatory! RSS links will fail without it. Notice the '~~' to produce a literal '~'
   :rss-item-number 10                                  ;; limit total amount of items in RSS feed to 10
   :date-format "%DayNumber %MonthName %Year"           ;; format for date %DayNumber %DayName %MonthNumber %MonthName %Year
   :date-format-title "%DayNumber-%MonthNumber-%Year"   ;; format for date %DayNumber %DayName %MonthNumber %MonthName %Year

   :default-converter :markdown2
   :html   t                                            ;; 't' to enable export to a html website / 'nil' to disable
   :gopher t                                            ;; 't' to enable export to a gopher website / 'nil' to disable
   :gemini t                                            ;; 't' to enable export to a gemini capsule / 'nil' to disable
   :gemini-path      "gemini://localhost"          ;; absolute path of your gemini capsule
   :gemini-index     "index.md"                         ;; filename of index file
   :gopher-path      "./"                            ;; absolute path of your gopher directory
   :gopher-server    "localhost"                       ;; hostname of the gopher server
   :gopher-port      "7070"                               ;; tcp port of the gopher server, 70 usually
   :gopher-format "[~d|~a|~a|~a|~a]~%"                  ;; menu format (geomyidae)
   :gopher-index "index.gph"                            ;; menu file   (geomyidae)
   ;; :gopher-format "~d~a	~a	~a	~a~%"   ;; menu format (gophernicus and others)
   ;; :gopher-index "gophermap"                         ;; menu file (gophernicus and others)
   ))


(converter :name :markdown  :extension ".md"  :command "peg-markdown -t html -o %OUT data/%IN")
(converter :name :markdown2 :extension ".md"  :command "multimarkdown -t html -o %OUT data/%IN")
(converter :name :org-mode  :extension ".org"
	   :command (concatenate 'string
				 "emacs data/%IN --batch --eval '(with-temp-buffer (org-mode) "
				 "(insert-file \"%IN\") (org-html-export-as-html nil nil nil t)"
				 "(princ (buffer-string)))' --kill | tee %OUT"))

;; Define your articles and their display-order on the website below.
;; Display Order is 'lifo', i.e. the top entry in this list gets displayed as the topmost entry.
;; 
;; An Example Of A Minimal Definition:
;; (post :id "4" :date "2015-12-31" :title "Happy new year" :tag "news")

;; An Example Of A Definitions With Options:
;; (post :id "4" :date "2015-05-04" :title "The article title" :tag "news" :author "Me" :tiny "Short description for home page")
;;
;; A Note On Keywords:
;; :author  can be omitted.   If so, it's value gets replaced by the value of :webmaster.
;; :tiny    can be omitted.   If so, the article's full text gets displayed on the all-articles view. (most people don't want this.)

;; library of babel filesystem
(post :title "Google CTF 2021 - Memsaftey"
      :tiny "Sandbox escape gone wrong"
      :id "memsafety" :date "20230628" :tag "rust ctf")

;; library of babel filesystem
(post :title "LOBFS - Library of Babel File System"
      :tiny "Infinite ephemeral knowledge~"
      :id "lobfs" :date "20230617" :tag "golang literature")

;; window kernel resources
(post :title "Window Kernel Resources"
      :tiny "personal notes ~ not for faint of heart"
      :id "windowskernel" :date "20230615" :tag "windows-interals window-kernel kernel pwn notes")

;; cl-yag rewrite
(post :title "New Website using cl-yag"
      :tiny "Static website generator written in pure Common Lisp"
      :id "cl-yag" :date "20230610" :tag "lisp this-website web")


;; rust patterns post
(post :title "Why I love Rust: Pattern Matching"
      :tiny "Rusted Love <3"
      :id "rustpatterns" :date "20230516" :tag "rust software-design")

;; persistence post
;; (post :title "Demonstration of Malware Persistence through Microsoft Internet Explorer"
;;       :tiny "Browser hell \\0/"
;;       :id "iepersistence" :date "20230514" :tag "malware persistence windows")

;; softmmu post
(post :title "pwnable.kr's softmmu - An Awesome Linux Kernel Exploit"
      :tiny "An important milestone for me"
      :id "softmmu" :date "20230212" :tag "linux-kernel kernel linux pwn ctf")