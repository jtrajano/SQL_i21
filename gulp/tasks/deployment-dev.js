/**
 * **************************************************************************
 * *       *           *           *           *              *             *
 *                           Artifact Deployment
 * *       *           *           *           *              *             *
 * ************************************************************************** 
 */
var gulp = require('gulp');
var changed = require('gulp-changed');
var config = require('../config');
config.env = 'dev';

gulp.task('publish', function () {
    gulp.src(['app/**/*.{js,css,svg,png,jpg}'])
        .pipe(changed(config.path.dest))
        .pipe(gulp.dest(config.path.dest));
});

gulp.task('publish-all', function () {
    gulp.src(['app/**/*.{js,css,svg,png,jpg}'])
        .pipe(gulp.dest(config.path.dest));
});

gulp.task('watch', function () {
    gulp.watch('app/**/*.{js,css,svg,png,jpg}', ['publish']);
});

gulp.task('default', ['publish', 'watch']);