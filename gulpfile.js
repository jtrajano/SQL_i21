var gulp = require('gulp');
//var livereload = require('gulp-livereload');

var source = './app';
var destination = '../../../artifacts/16.3/Inventory/app';

var path = require('path');
var merge = require('merge-stream');
var gulp = require('gulp');
var concat = require('gulp-concat');
var rename = require('gulp-rename');
var uglify = require('gulp-uglify');
var genSpec = require('./lib/gulp-plugins/i21-gen-spec');
var genSpec2 = require('./lib/gulp-plugins/i21-gen-spec2');
var prettify = require('gulp-js-prettify');
var os = require('os');
var open = require('gulp-open');

var Server = require('karma').Server;

gulp.task('publish', function () {
    gulp.src(['app/**/*.js'])
        .pipe(gulp.dest(destination))
});

gulp.task('watch', function () {
    gulp.watch('app/**/*.js', ['publish']);
});

gulp.task('generate-specs-model', function () {
    gulp.src('app/model/*.js')
        .pipe(genSpec2({
            type: "model",
            moduleName: "Inventory",
            destDir: "test/specs"
        }))
        .pipe(prettify({collapseWhitespace: true}))
        .pipe(gulp.dest('test/specs'));
});

gulp.task('test', function(done) {
    new Server({
        configFile: __dirname + '/karma.conf.js',
        singleRun: false,
    }, done).start();
});

gulp.task('open', function(){
  gulp.src('karma_html/report-summary-filename/index.html')
  .pipe(open());
});

var browser = os.platform() === 'linux' ? 'google-chrome' : (
  os.platform() === 'darwin' ? 'google chrome' : (
  os.platform() === 'win32' ? 'chrome' : 'firefox'));

gulp.task('browser', function(){
  gulp.src('karma_html/report-summary-filename/index.html')
  .pipe(open({app: browser}));
});;

gulp.task('test-report', ['test'], function(done) {
    gulp.start('browser');
});

gulp.task('default', ['publish', 'watch']);