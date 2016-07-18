gulp = require 'gulp'
bower = require 'bower'
sass = require 'gulp-sass'
less = require 'gulp-less'
concat = require 'gulp-concat'
merge = require 'streamqueue'
minify = require 'gulp-minify-css'
rename = require 'gulp-rename'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
templateCache = require 'gulp-angular-templatecache'

gulp.task 'default', ['css', 'template', 'coffee']

gulp.task 'css', ->
  [lessAll, scssAll, cssAll] = [
    gulp.src ['./scss/bootstrap.less']
      .pipe less()
      .pipe concat 'less-files.less'
    gulp.src ['./scss/ionic.app.scss']
      .pipe sass()
      .pipe concat 'scss-files.scss'
    gulp.src ['./www/lib/angular-xeditable/dist/css/xeditable.css']
      .pipe concat 'css-files.css'
  ]
  merge objectMode: true, lessAll, scssAll, cssAll
    .pipe concat 'ionic.app.css'
    .pipe gulp.dest './www/css/'
    .pipe minify()
    .pipe(rename({ extname: '.min.css' }))
    .pipe(gulp.dest('./www/css/'))

gulp.task 'coffee', ->
  browserify(entries: ['./www/js/index.coffee'])
    .transform('coffeeify')
    .transform('debowerify')
    .bundle()
    .pipe(source('index.js'))
    .pipe(gulp.dest('./www/js/'))

gulp.task 'template', ->
  gulp.src('./www/templates/**/*.html')
    .pipe(templateCache(root: 'templates', standalone: true))
    .pipe(gulp.dest('./www/js/'))
