var gulp = require('gulp');
var gutil = require('gulp-util');
var uglify = require('gulp-uglify');
var concat = require('gulp-concat');
var templateCache = require('gulp-angular-templatecache');
var minifyCss = require('gulp-minify-css');
var rename = require('gulp-rename');
var ngAnnotate = require('gulp-ng-annotate');

var config = {
  js:[
    'js/main.js',
    'js/ctrls/**/*.js',
    'js/services.js'
  ]
};

gulp.task('default', ['javascript']);


/** Main Gulp Tasks */
/** ------------------------------------------------------------------------- */
////////////////////////////////////////////////////////////////////////////////

  gulp.task('javascript', function(done) {
    gulp.src(config.js)
    .pipe(ngAnnotate())
    .pipe(uglify())
    .pipe(concat('app.min.js'))
    .pipe(gulp.dest('./js/dist'))
    .on('end', done);
  });
