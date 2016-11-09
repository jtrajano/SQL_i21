var source = './app';
var destination = '../../../artifacts/16.4/Inventory/app';

var gulp = require('gulp');
var prettify = require('gulp-js-prettify');
var changed = require('gulp-changed');
var Server = require('karma').Server;
var gen = require('gulp-extjs-spec-generator');

/**
 * **************************************************************************
 * *       *           *           *           *              *             *
 *                        Unit Test Specs Generation
 * *       *           *           *           *              *             *
 * ************************************************************************** 
 */

/**
 * **************************************************************************
 * *       *           *           *           *              *             *
 *                            Unit Testing
 * *       *           *           *           *              *             *
 * ************************************************************************** 
 */
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


/**
 * **************************************************************************
 * *       *           *           *           *              *             *
 *                           Artifact Deployment
 * *       *           *           *           *              *             *
 * ************************************************************************** 
 */
gulp.task('publish', function () {
    gulp.src(['app/**/*.js'])
        .pipe(changed(destination))
        .pipe(gulp.dest(destination));
});

gulp.task('publish-all', function () {
    gulp.src(['app/**/*.js'])
        .pipe(gulp.dest(destination));
});

gulp.task('watch', function () {
    gulp.watch('app/**/*.js', ['publish']);
});

gulp.task('default', ['publish', 'watch']);