var source = './app';
var destination = '../../../artifacts/17.2/Inventory/app';

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

var destDir = 'test/specs';
function getConfig(type) {
    return {
        type: type,
        moduleName: "Inventory",
        dependencyDir: "app/**/*.js",
        resolveModuleDependencies: true,
        destDir: destDir,
        formatContent: true,
        dependencyDestDir: "test/mock"    
    };
}

/**
 * ===================================================
 *            Generate Specs Asynchronuously
 * ===================================================
 */

gulp.task('spec-m', function() {
    return gulp.src('app/model/**/*.js')
        .pipe(gen(getConfig("model")))
        .pipe(gulp.dest(destDir));
});

gulp.task('spec-s', function() {
    return gulp.src('app/store/**/*.js')
        .pipe(gen(getConfig("store")))
        .pipe(gulp.dest(destDir));
});

gulp.task('spec-vc', function() {
    return gulp.src('app/view/**/*.js')
        .pipe(gen(getConfig("viewcontroller")))
        .pipe(gulp.dest(destDir));
});

gulp.task("spec",["spec-m", "spec-s", "spec-vc"]);

/**
 * ===================================================
 *            Generate Specs Synchronuously
 * ===================================================
 */
gulp.task('spec-s-sync', ['spec-m'], function() {
    return gulp.src('app/store/**/*.js')
        .pipe(gen(getConfig("store")))
        .pipe(gulp.dest(destDir));
});

gulp.task('spec-vc-sync', ['spec-s-sync'], function() {
    return gulp.src('app/view/**/*.js')
        .pipe(gen(getConfig("viewcontroller")))
        .pipe(gulp.dest(destDir));
});

gulp.task("spec-sync",["spec-vc-sync"]);

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