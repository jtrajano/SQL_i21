var gulp = require('gulp');
var livereload = require('gulp-livereload');

var source = './app';
var destination = '../../../artifacts/16.3/Inventory/app';

var fs = require('fs');
var path = require('path');
var merge = require('merge-stream');
var gulp = require('gulp');
var concat = require('gulp-concat');
var rename = require('gulp-rename');
var uglify = require('gulp-uglify');
var fcg = require('./lib/gulp-plugins/gulp-extjs-get-classname');
var prettify = require('gulp-js-prettify');

var scriptsPath = 'src/scripts';

function getFolders(dir) {
    return fs.readdirSync(dir)
        .filter(function (file) {
            return fs.statSync(path.join(dir, file)).isDirectory();
        });
}

gulp.task('publish', function () {
    gulp.src(['app/**/*.js'])
        .pipe(gulp.dest(destination))
});

gulp.task('watch', function () {
    gulp.watch('app/**/*.js', ['publish']);
});

gulp.task('generate-specs-model', function () {
    gulp.src('app/model/*.js')
        //.pipe(rename('main.min.js'))
        .pipe(fcg())
        .pipe(prettify({collapseWhitespace: true}))
        .pipe(gulp.dest('test/specs'));
});

gulp.task('default', ['publish', 'watch']);