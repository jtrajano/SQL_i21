/**
 * **************************************************************************
 * *       *           *           *           *              *             *
 *                            Unit Testing
 * *       *           *           *           *              *             *
 * ************************************************************************** 
 */

var gulp = require('gulp');
var Server = require('karma').Server;
var config = require('../config');
var inlinesource = require('gulp-inline-source');

gulp.task('test', function (done) {
    new Server({
        configFile: config.testing.config,
        singleRun: true,
        reporters: ['mocha', 'junit', 'coverage']
    }, done).start();
});

/* VSTS blocked css & scripts for code coverage so we need to generate a new html file with all scripts and css transformed inline. */
gulp.task('style-coverage', function (done) {
    return gulp.src('./coverage/html/*.html')
        .pipe(inlinesource({attribute: false}))
        .pipe(gulp.dest('./coverage/html/inline-index.html'));
});

gulp.task('test-coverage', ['test'], function() {
    gulp.start('style-coverage');
});
/* --------------------------------------------- */

gulp.task('test-mocha', function (done) {
    new Server({
        configFile: config.testing.config,
        singleRun: false,
        reporters: 'nyan'
    }, done).start();
});

gulp.task('test-nyan', function (done) {
    new Server({
        configFile: config.testing.config,
        singleRun: false,
        reporters: 'nyan'
    }, done).start();
});

gulp.task('test-single', function (done) {
    new Server({
        configFile: config.testing.single,
        singleRun: false,
        reporters: 'mocha'
    }, done).start();
});