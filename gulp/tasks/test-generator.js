/**
 * **************************************************************************
 * *       *           *           *           *              *             *
 *                        Unit Test Specs Generation
 * *       *           *           *           *              *             *
 * ************************************************************************** 
 */
var gulp = require('gulp');
var prettify = require('gulp-js-prettify');
var gen = require('gulp-extjs-spec-generator');

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