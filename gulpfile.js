var gulp = require('gulp');
var livereload = require('gulp-livereload');

var source = './app';
var destination = '../../../artifacts/16.4/Inventory/app';

gulp.task('publish', function() {
    gulp.src(['app/**/*.js'])
    .pipe(gulp.dest(destination))
    //.pipe(livereload());
});

gulp.task('watch', function() {
    // livereload.listen({
    //     port: 80
    // });
    gulp.watch('app/**/*.js', ['publish']);
});

gulp.task('default', ['publish', 'watch']);