;;;; GLOBAL VARIABLES

(defparameter *articles* '())
(defparameter *converters* '())
(defparameter *days* '("Monday" "Tuesday" "Wednesday" "Thursday"
                       "Friday" "Saturday" "Sunday"))
(defparameter *months* '("January" "February" "March" "April"
                         "May" "June" "July" "August" "September"
                         "October" "November" "December"))

;; structure to store links
(defstruct article title tag date id tiny author rawdate converter)
(defstruct converter name command extension)

;;;; FUNCTIONS

(require 'asdf)

;; return the day of the week
(defun get-day-of-week(day month year)
  (multiple-value-bind
   (second minute hour date month year day-of-week dst-p tz)
   (decode-universal-time (encode-universal-time 0 0 0 day month year))
   (declare (ignore second minute hour date month year dst-p tz))
   day-of-week))

;; parse the date to
(defun date-parse(date)
  (if (= 8 (length date))
      (let* ((year     (parse-integer date :start 0 :end 4))
             (monthnum (parse-integer date :start 4 :end 6))
             (daynum   (parse-integer date :start 6 :end 8))
             (day      (nth (get-day-of-week daynum monthnum year) *days*))
             (month    (nth (- monthnum 1) *months*)))
        (list
         :dayname day
         :daynumber daynum
         :monthname month
         :monthnumber monthnum
         :year year))
    nil))

(defun post(&optional &key title tag date id (tiny nil) (author (getf *config* :webmaster)) (converter nil))
  (push (make-article :title title
                      :tag tag
                      :date (date-parse date)
                      :rawdate date
                      :tiny tiny
                      :author author
                      :id id
                      :converter converter)
        *articles*))

;; we add a converter to the list of the one availables
(defun converter(&optional &key name command extension)
  (setf *converters*
        (append
         (list name
               (make-converter :name name
                               :command command
                               :extension extension))
         *converters*)))

;; load data from metadata and load config
(load "data/articles.lisp")
(setf *articles* (reverse *articles*))

  ;; common-lisp don't have a replace string function natively
  (defun replace-all (string part replacement &key (test #'char=))
    (with-output-to-string (out)
      (loop with part-length = (length part)
        for old-pos = 0 then (+ pos part-length)
        for pos = (search part string
                          :start2 old-pos
                          :test test)
        do (write-string string out
                          :start old-pos
                          :end (or pos (length string)))
        when pos do (write-string replacement out)
        while pos)))

  ;; common-lisp don't have a split string function natively
  (defun split-str(text &optional (separator #\Space))
    "this function split a string with separator and return a list"
    (let ((text (concatenate 'string text (string separator))))
      (loop for char across text
        counting char into count
        when (char= char separator)
        collect
        ;; we look at the position of the left separator from right to left
          (let ((left-separator-position (position separator text :from-end t :end (- count 1))))
            (subseq text
                    ;; if we can't find a separator at the left of the current, then it's the start of
                    ;; the string
                    (if left-separator-position (+ 1 left-separator-position) 0)
                    (- count 1))))))

;; load a file as a string
;; we escape ~ to avoid failures with format
(defun load-file(path)
  (if (probe-file path)
      (with-open-file (stream path)
        (let* ((file-size (file-length stream))
               (contents (make-string file-size)))
          (read-sequence contents stream)
          (setf contents (remove #\null contents)) ; Remove null bytes
          (coerce contents 'string)))
    (progn
      (format t "ERROR: file ~a not found. Aborting~%" path)
      (quit))))

;; save a string in a file
(defun save-file(path data)
  (with-open-file (stream path :direction :output :if-exists :supersede)
		  (write-sequence data stream)))

;; simplify the str replace work
(defmacro template(before &body after)
  `(progn
     (setf output (replace-all output ,before ,@after))))

;; get the converter object of "article"
(defmacro with-converter(&body code)
  `(progn
     (let ((converter-name (if (article-converter article)
			       (article-converter article)
			     (getf *config* :default-converter))))
       (let ((converter-object (getf *converters* converter-name)))
	 ,@code))))

;; generate the html file from the source file
;; using the converter associated with the post
(defun use-converter-to-html(filename &optional (converter-name nil))
  (let* ((converter-object (getf *converters*
                                 (or converter-name
			             converter-name
			             (getf *config* :default-converter))))
         (output           (converter-command converter-object))
         (src-file (format nil "~a~a" filename (converter-extension converter-object)))
         (dst-file (format nil "temp/data/~a.html" filename ))
         (full-src-file (format nil "data/~a" src-file)))
      ;; skip generating if the destination exists
      ;; and is more recent than source
      (unless (and
               (probe-file dst-file)
               (>=
                (file-write-date dst-file)
                (file-write-date full-src-file)))
        (ensure-directories-exist "temp/data/")
        (template "%IN" src-file)
        (template "%OUT" dst-file)
        (format t "~a~%" output)
        (uiop:run-program output))))

;; format the date
(defun date-format(format date)
  (let ((output format))
    (template "%DayName"     (getf date :dayname))
    (template "%DayNumber"   (format nil "~2,'0d" (getf date :daynumber)))
    (template "%MonthName"   (getf date :monthname))
    (template "%MonthNumber" (format nil "~2,'0d" (getf date :monthnumber)))
    (template "%Year"        (write-to-string (getf date :year )))
    output))

;; simplify the declaration of a new page type
(defmacro prepare(template &body code)
  `(progn
     (let ((output (load-file ,template)))
       ,@code
       output)))

;; simplify the file saving by using the layout
(defmacro generate(name &body data)
  `(progn
     (save-file ,name (generate-layout ,@data))))

;; generate a gemini index file
(defun generate-gemini-index(articles)
  (let ((output (load-file "templates/gemini_head.tpl")))
    (dolist (article articles)
      (setf output
	    (string
	     (concatenate 'string output
                          (format nil "=> ~a/articles/~a.gmi ~a-~2,'0d-~2,'0d ~a~%"
                                  (getf *config* :gemini-path)
                                  (article-id article)
                                  (getf (article-date article) :year)
                                  (getf (article-date article) :monthnumber)
                                  (getf (article-date article) :daynumber)
                                  (article-title article))))))
    output))

;; generate a gopher index file
(defun generate-gopher-index(articles)
  (let ((output (load-file "templates/gopher_head.tpl")))
    (dolist (article articles)
      (setf output
	    (string
	     (concatenate 'string output
                          (format nil (getf *config* :gopher-format)
                                  0 ;;;; gopher type, 0 for text files
				  ;; here we create a 80 width char string with title on the left
				  ;; and date on the right
				  ;; we truncate the article title if it's too large
				  (let ((title (format nil "~80a"
						       (if (< 80 (length (article-title article)))
							   (subseq (article-title article) 0 80)
							   (article-title article)))))
				    (replace title (article-rawdate article) :start1 (- (length title) (length (article-rawdate article)))))
				  (concatenate 'string
                                               (getf *config* :gopher-path) "/article-" (article-id article) ".txt")
				  (getf *config* :gopher-server)
				  (getf *config* :gopher-port)
				  )))))
    output))

;; generate the list of tags
(defun articles-by-tag()
  (let ((tag-list))
    (loop for article in *articles* do
	  (when (article-tag article) ;; we don't want an error if no tag
	    (loop for tag in (split-str (article-tag article)) do ;; for each word in tag keyword
		  (setf (getf tag-list (intern tag "KEYWORD")) ;; we create the keyword is inexistent and add ID to :value
			(list
			 :name tag
			 :value (push (article-id article) (getf (getf tag-list (intern tag "KEYWORD")) :value)))))))
    (loop for i from 1 to (length tag-list) by 2 collect ;; removing the keywords
	  (nth i tag-list))))

;; generates the html of the list of tags for an article
(defun get-tag-list-article(&optional article)
  (apply #'concatenate 'string
         (mapcar #'(lambda (item)
                     (prepare "templates/one-tag.tpl" (template "%%Name%%" item)))
                 (split-str (article-tag article)))))

;; generates the html of the whole list of tags
(defun get-tag-list()
  (apply #'concatenate 'string
         (mapcar #'(lambda (item)
                     (prepare "templates/one-tag.tpl"
                              (template "%%Name%%" (getf item :name))))
                 (articles-by-tag))))


;; generates the html of only one article
;; this is called in a loop to produce the homepage
(defun create-article(article &optional &key (tiny t) (no-text nil) (title-only nil))
  (let ((template-file (if title-only
                         "templates/article-title.tpl"
                         "templates/article.tpl")))
    (prepare template-file
       (template "%%Author%%" (let ((author (article-author article)))
                                (or author (getf *config* :webmaster))))
        (template "%%Date%%"   (date-format (getf *config* (if title-only :date-format-title :date-format))
                                    (article-date article)))
       (template "%%Raw-Date%%" (article-rawdate article))
       (template "%%Title%%"  (article-title article))
       (template "%%Id%%"     (article-id article))
       (template "%%Tags%%"   (get-tag-list-article article))
       (template "%%About-Short%%"   (load-file "templates/about-short.tpl"))
       (template "%%Date-Url%%"  (date-format "%Year-%MonthNumber-%DayNumber"
                                              (article-date article)))
       (template "%%Text%%"   (if no-text
                                  ""
                                  (if (and tiny (article-tiny article))
                                      (format nil "<p>~a</p>" (article-tiny article))
                                      (load-file (format nil "temp/data/~d.html" (article-id article)))))))))

;; return a html string
;; produce the code of a whole page with title+layout with the parameter as the content
(defun generate-layout(body &optional &key (title nil))
  (prepare "templates/layout.tpl"
	   (template "%%Title%%" (if title title (getf *config* :title)))
	   (template "%%Tags%%" (get-tag-list))
	   (template "%%Body%%" body)
	   output))


(defun generate-semi-mainpage(&key (tiny t) (no-text nil) (title-only t) (year-title t))
  (let* ((header-template (prepare "templates/about.tpl"))
         (sorted-articles (sort *articles* #'> :key (lambda (article) 
                                                    (getf (article-date article) :year))))
         (final-strings (list header-template))
         (current-year nil))
    (loop for article in sorted-articles do
         (let ((article-year (getf (article-date article) :year)))
           (when (and year-title (not (equal article-year current-year)))
             (setf current-year article-year)
             (push (format nil "<h2>~a</h2>" article-year) final-strings))
           (push (create-article article :tiny tiny :no-text no-text :title-only title-only) final-strings)))
    (apply #'concatenate 'string (reverse final-strings))))


;; html generation of a tag homepage
(defun generate-tag-mainpage(articles-in-tag)
  (let* ((tag-articles (remove-if-not #'(lambda (article) 
                                          (member (article-id article) articles-in-tag :test #'equal))
                                      *articles*))
         (sorted-articles (sort tag-articles #'> :key (lambda (article)
                                                       (getf (article-date article) :year))))
         (final-strings '())
         (current-year nil))
    (loop for article in sorted-articles do
         (let ((article-year (getf (article-date article) :year)))
           (when (not (equal article-year current-year))
             (setf current-year article-year)
             (push (format nil "<h2>~a</h2>" article-year) final-strings))
           (push (create-article article :tiny t :no-text t :title-only t) final-strings)))
    (apply #'concatenate 'string (reverse final-strings))))

;; xml generation of the items for the rss
(defun generate-rss-item(&key (gopher nil))
  (apply #'concatenate 'string
         (loop for article in *articles*
            for i from 1 to (min (length *articles*) (getf *config* :rss-item-number))
            collect
              (prepare "templates/rss-item.tpl"
                       (template "%%Title%%" (article-title article))
                       (template "%%Description%%" (load-file (format nil "temp/data/~d.html" (article-id article))))
		       (template "%%Date%%" (format nil
						    (date-format "~a, %DayNumber ~a %Year 00:00:00 GMT"
								 (article-date article))
						    (subseq (getf (article-date article) :dayname) 0 3)
						    (subseq (getf (article-date article) :monthname) 0 3)))
                       (template "%%Url%%"
                                 (if gopher
                                     (format nil "gopher://~a:~d/0~a/article-~a.txt"
					     (getf *config* :gopher-server)
					     (getf *config* :gopher-port)
                                             (getf *config* :gopher-path)
					     (article-id article))
                                     (format nil "~d~d-~d.html"
                                             (getf *config* :url)
                                             (date-format "%Year-%MonthNumber-%DayNumber"
                                                          (article-date article))
                                             (article-id article))))))))


;; Generate the rss xml data
(defun generate-rss(&key (gopher nil))
  (prepare "templates/rss.tpl"
	   (template "%%Description%%" (getf *config* :description))
	   (template "%%Title%%" (getf *config* :title))
	   (template "%%Url%%" (getf *config* :url))
	   (template "%%Items%%" (generate-rss-item :gopher gopher))))

;; We do all the website
(defun create-html-site()

  ;; produce each article file
  (loop for article in *articles*
     do
     ;; use the article's converter to get html code of it
       (use-converter-to-html (article-id article) (article-converter article))

	(generate  (format nil "output/html/~d-~d.html"
			   (date-format "%Year-%MonthNumber-%DayNumber"
					(article-date article))
			   (article-id article))
		   (create-article article :tiny nil)
		   :title (concatenate 'string (getf *config* :title) " : " (article-title article))))

  ;; produce index.html
  (generate "output/html/index.html" (generate-semi-mainpage))

  ;; produce index-titles.html where there are only articles titles
  (generate "output/html/index-titles.html" (generate-semi-mainpage :no-text nil :tiny nil :title-only nil :year-title nil))

  ;; produce index file for each tag
  (loop for tag in (articles-by-tag) do
       (generate (format nil "output/html/tag-~d.html" (getf tag :NAME))
		  (generate-tag-mainpage (getf tag :VALUE))))

  ;; generate rss gopher in html folder if gopher is t
  (when (getf *config* :gopher)
    (save-file "output/html/rss-gopher.xml" (generate-rss :gopher t)))

  ;;(generate-file-rss)
  (save-file "output/html/rss.xml" (generate-rss)))

;; we do all the gemini capsule
(defun create-gemini-capsule()

  ;; produce the index.gmi file
  (save-file (concatenate 'string "output/gemini/" (getf *config* :gemini-index))
             (generate-gemini-index *articles*))

  ;; produce a tag list menu
  (let* ((directory-path "output/gemini/_tags_/")
         (index-path (concatenate 'string directory-path (getf *config* :gemini-index))))
    (ensure-directories-exist directory-path)
    (save-file index-path
               (let ((output (load-file "templates/gemini_head.tpl")))
                 (loop for tag in
                      ;; sort tags per articles in it
                      (sort (articles-by-tag) #'>
                            :key #'(lambda (x) (length (getf x :value))))
                    do
                      (setf output
	                    (string
	                     (concatenate
                              'string output
                              (format nil "=> ~a/~a/index.gmi ~a ~d~%"
                                      (getf *config* :gemini-path)
                                      (getf tag :name)
                                      (getf tag :name)
                                      (length (getf tag :value)))))))
                 output)))

  ;; produce each tag gemini index
  (loop for tag in (articles-by-tag) do
       (let* ((directory-path (concatenate 'string "output/gemini/" (getf tag :NAME) "/"))
              (index-path (concatenate 'string directory-path (getf *config* :gemini-index)))
              (articles-with-tag (loop for article in *articles*
                                    when (member (article-id article) (getf tag :VALUE) :test #'equal)
                                    collect article)))
         (ensure-directories-exist directory-path)
         (save-file index-path (generate-gemini-index articles-with-tag))))

  ;; produce each article file (adding some headers)
  (loop for article in *articles*
     do
       (with-converter
	   (let ((id (article-id article)))
	     (save-file (format nil "output/gemini/articles/~a.gmi" id)
                        (format nil "~{~a~}"
                                (list
                                 "Title : " (article-title article) #\Newline
                                 "Author: " (article-author article) #\Newline
                                 "Date  : " (date-format (getf *config* :date-format) (article-date article)) #\Newline
                                 "Tags  : " (article-tag article) #\Newline #\Newline
		                 (load-file (format nil "data/~d~d" id (converter-extension converter-object))))))))))

;; we do all the gopher hole
(defun create-gopher-hole()

  ;;(generate-file-rss)
  (save-file "output/gopher/rss.xml" (generate-rss :gopher t))

  ;; produce the gophermap file
  (save-file (concatenate 'string "output/gopher/" (getf *config* :gopher-index))
             (generate-gopher-index *articles*))

  ;; produce a tag list menu
  (let* ((directory-path "output/gopher/_tags_/")
         (index-path (concatenate 'string directory-path (getf *config* :gopher-index))))
    (ensure-directories-exist directory-path)
    (save-file index-path
               (let ((output (load-file "templates/gopher_head.tpl")))
                 (loop for tag in
                      ;; sort tags per articles in it
                      (sort (articles-by-tag) #'>
                            :key #'(lambda (x) (length (getf x :value))))
                    do
                      (setf output
	                    (string
	                     (concatenate
                              'string output
                              (format nil (getf *config* :gopher-format)
                                      1 ;; gopher type, 1 for menus
                                      ;; here we create a 72 width char string with title on the left
				      ;; and number of articles on the right
				      ;; we truncate the article title if it's too large
				      (let ((title (format nil "~72a"
						           (if (< 72 (length (getf tag :NAME)))
							       (subseq (getf tag :NAME) 0 80)
							       (getf tag :NAME))))
                                            (article-number (format nil "~d article~p" (length (getf tag :value)) (length (getf tag :value)))))
				        (replace title article-number :start1 (- (length title) (length article-number))))
                                      (concatenate 'string
                                                   (getf *config* :gopher-path) "/" (getf tag :NAME) "/")
				      (getf *config* :gopher-server)
				      (getf *config* :gopher-port)
				      )))))
                 output)))

  ;; produce each tag gophermap index
  (loop for tag in (articles-by-tag) do
       (let* ((directory-path (concatenate 'string "output/gopher/" (getf tag :NAME) "/"))
              (index-path (concatenate 'string directory-path (getf *config* :gopher-index)))
              (articles-with-tag (loop for article in *articles*
                                    when (member (article-id article) (getf tag :VALUE) :test #'equal)
                                    collect article)))
         (ensure-directories-exist directory-path)
         (save-file index-path (generate-gopher-index articles-with-tag))))

  ;; produce each article file (adding some headers)
  (loop for article in *articles*
     do
       (with-converter
	   (let ((id (article-id article)))
	     (save-file (format nil "output/gopher/article-~d.txt" id)
                        (format nil "Title: ~a~%Author: ~a~%Date: ~a~%Tags: ~a~%============~%~%~a"
                                 (article-title article)
                                 (article-author article)
                                 (date-format (getf *config* :date-format) (article-date article))
                                 (article-tag article)
		                         (load-file (format nil "data/~d~d" id (converter-extension converter-object)))))))))


;; This is function called when running the tool
(defun generate-site()
  (if (getf *config* :html)
      (create-html-site))
  (if (getf *config* :gemini)
      (create-gemini-capsule))
  (if (getf *config* :gopher)
      (create-gopher-hole)))

;;;; EXECUTION

(generate-site)

(quit)
