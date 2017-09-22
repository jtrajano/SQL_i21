var source = './app';
var destination = '../../../artifacts/17.3/Inventory/debug/app';
var test_ui_dest = '../../../../QC1730/Inventory/test-ui';
var changed = require('gulp-changed');

var gulp = require('gulp');
var requireDir  = require('require-dir');

requireDir('./gulp/tasks', {recurse: false});

gulp.task('publish-test-ui', function () {
    gulp.src(['test-ui/**/*.*'])
        .pipe(changed(test_ui_dest))
        .pipe(gulp.dest(test_ui_dest));
});

gulp.task('watch-test-ui', function () {
    gulp.watch('test-ui/**/*.*', ['publish-test-ui']);
});

gulp.task('test-ui', ['watch-test-ui']);