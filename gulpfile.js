var source = './app';
var destination = '../../../artifacts/16.3/Inventory/app';

var gulp = require('gulp');
var concat = require('gulp-concat');
var rename = require('gulp-rename');
var uglify = require('gulp-uglify');
var spec = require('./lib/gulp-plugins/i21-gen-spec');
var prettify = require('gulp-js-prettify');
var os = require('os');
var open = require('gulp-open');
var changed = require('gulp-changed');

var Server = require('karma').Server;

gulp.task('publish', function () {
    gulp.src(['app/**/*.js'])
        .pipe(changed(destination))
        .pipe(gulp.dest(destination))
});

gulp.task('watch', function () {
    gulp.watch('app/**/*.js', ['publish']);
});

gulp.task('generate-specs-model', function () {
    gulp.src('app/model/*.js')
        .pipe(spec({
            type: "model",
            moduleName: "Inventory",
            destDir: "test/specs",
            dependencyDestDir: "test/mock"
        }))
        .pipe(prettify({collapseWhitespace: true}))
        .pipe(gulp.dest('test/specs'));
});

gulp.task('generate-specs-store', function () {
    gulp.src('app/store/*.js')
        .pipe(spec({
            type: "store",
            moduleName: "Inventory",
            destDir: "test/specs",
            dependencyDestDir: "test/mock"
        }))
        .pipe(prettify({collapseWhitespace: true}))
        .pipe(gulp.dest('test/specs'));
});

gulp.task('generate-specs-viewcontroller', function () {
    gulp.src(['app/view/*.js'])
        .pipe(spec({
            type: "viewcontroller",
            moduleName: "Inventory",
            destDir: "test/specs",
            dependencyDestDir: "test/mock"
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

gulp.task('test-mocha', function(done) {
    new Server({
        configFile: __dirname + '/karma.conf.js',
        singleRun: false,
        reporters: 'mocha'
    }, done).start();
});

gulp.task('test-single', function(done) {
    new Server({
        configFile: __dirname + '/karma.single.conf.js',
        singleRun: false,
        reporters: 'mocha'
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

gulp.task('generate-specs', ['generate-specs-model', 'generate-specs-store', 'generate-specs-viewcontroller']);