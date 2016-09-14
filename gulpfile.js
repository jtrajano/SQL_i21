var gulp = require('gulp');
var source = './app';
var destination = '../../artifacts/16.3/Inventory/app';

gulp.task('publish', function() {
    gulp.src(['app/**/*.js'])
    .pipe(gulp.dest(destination));
});

gulp.task('watch', function() {
    gulp.watch('app/**/*.js', ['publish']);
});

gulp.task('default', ['publish', 'watch']);