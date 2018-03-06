var env = 'dev';
var src = './app';
var dest_prod = '../../../artifacts/build/app/Inventory';
var dest_dev = '../../../artifacts/build/debug/app/Inventory';
var test_ui_dest = '../../../QC1730/Inventory/test-ui';

module.exports = {
    env: env,
    path: {
        src: src,
        dest: env === 'prod' ? dest_prod : dest_dev,
        testui: test_ui_dest
    },
    testing: {
        config: __dirname.replace('gulp', '') +  '/karma.conf.js',
        single: __dirname.replace('gulp', '') + '/karma.single.conf.js'
    }
};