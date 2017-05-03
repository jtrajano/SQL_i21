var env = 'dev';
var src = './app';
var dest_prod = '../../../artifacts/17.2/Inventory/app';
var dest_dev = '../../../artifacts/17.2/Inventory/debug/app';

module.exports = {
    env: env,
    path: {
        src: src,
        dest: env === 'prod' ? dest_prod : dest_dev
    },
    testing: {
        config: __dirname.replace('gulp', '') +  '/karma.conf.js'
    }
};