/**
 * **************************************************************************
 * *       *           *           *           *              *             *
 *                           Artifact Deployment
 * *       *           *           *           *              *             *
 * ************************************************************************** 
 */
var gulp = require('gulp');

gulp.task('publish', function () {
    gulp.src(['app/**/*.{js,css}'])
        .pipe(changed(destination))
        .pipe(gulp.dest(destination));
});

gulp.task('publish-all', function () {
    gulp.src(['app/**/*.{js,css}'])
        .pipe(gulp.dest(destination));
});

gulp.task('watch', function () {
    gulp.watch('app/**/*.{js,css}', ['publish']);
});

gulp.task('default', ['publish', 'watch']);