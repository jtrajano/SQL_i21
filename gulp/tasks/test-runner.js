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

gulp.task('test', function (done) {
    new Server({
        configFile: config.testing.config,
        singleRun: true,
        reporters: ['mocha', 'junit', 'coverage']
    }, done).start();
});

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