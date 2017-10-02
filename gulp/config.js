var env = 'prod';
var src = './app';
var dest_prod = '../../../artifacts/17.4.owa/app/Inventory';
var dest_dev = '../../../artifacts/17.4.owa/app/Inventory/debug';
var test_ui_dest = '../../../QC1730/Inventory/test-ui';

module.exports = {
    env: env,
    path: {
        src: src,
        dest: env === 'prod' ? dest_prod : dest_dev,
        testui: test_ui_dest
    },
    testing: {
        config: __dirname.replace('gulp', '') +  '/karma.conf.js'
    }
};