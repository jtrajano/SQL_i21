var gulp = require('gulp');
var changed = require('gulp-changed');
var browserSync = require('browser-sync').create();
var config = require('../config');
var browserify = require('gulp-browserify');

gulp.task('js', function () {
    return gulp.src(['app/view/**/*.{js,css}', 'app/model/**/*.{js,css}', 
        'app/search/**/*.{js,css}', 'app/store/**/*.{js,css}', 'app/ux/**/*.{js,css}', 'app/controller/**/*.{js,css}'])
        .pipe(browserify())
        .pipe(gulp.dest(config.path.dest));
});

gulp.task('js-watch', ['publish', 'js'], function (done) {
    browserSync.reload();
    done();
});

// use default task to launch Browsersync and watch JS files
gulp.task('reload', ['publish', 'js'], function () {

    // Serve files from the root of this project
    // browserSync.init({
    //     server: {
    //         baseDir: "./"
    //     }
    // });
    
    browserSync.init({
        // proxy: "http://localhost/17.2/i21/debug.html"
        proxy: "http://localhost:3000/17.2/i21/index.html"
    });

    gulp.watch('app/**/*.{js,css}', ['js-watch']);
});