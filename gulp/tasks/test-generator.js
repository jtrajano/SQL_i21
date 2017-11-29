/**
 * **************************************************************************
 * *       *           *           *           *              *             *
 *                        Unit Test Specs Generation
 * *       *           *           *           *              *             *
 * ************************************************************************** 
 */
var gulp = require('gulp');
var prettify = require('gulp-js-prettify');
var gen = require('gulp-extjs-spec-generator');

var aliasMappings = [
    { name: 'i21', prefix: 'sm' },
    { name: 'AccountsPayable', prefix: 'ap' },
    { name: 'AccountsReceivable', prefix: 'ar' },
    { name: 'CardFueling', prefix: 'cf' },
    { name: 'CashManagement', prefix: 'cm' },
    { name: 'CreditCardRecon', prefix: 'cc' },
    { name: 'ContractManagement', prefix: 'ct' },
    { name: 'CRM', prefix: 'crm' },
    { name: 'Dashboard', prefix: 'db' },
    { name: 'EnergyTrac', prefix: 'et' },
    { name: 'EntityManagement', prefix: 'em' },
    { name: 'FinancialReportDesigner', prefix: 'frd' },
    { name: 'GeneralLedger', prefix: 'gl' },
    { name: 'GlobalComponentEngine', prefix: 'frm' },
    { name: 'Grain', prefix: 'gr' },
    { name: 'HelpDesk', prefix: 'hd' },
    { name: 'Integration', prefix: 'ip' },
    { name: 'Inventory', prefix: 'ic' },
    { name: 'Logistics', prefix: 'lg' },
    { name: 'Manufacturing', prefix: 'mf' },
    { name: 'MeterBilling', prefix: 'mb' },
    { name: 'NoteReceivable', prefix: 'nr' },
    { name: 'Patronage', prefix: 'pat' },
    { name: 'Payroll', prefix: 'pr' },
    { name: 'Quality', prefix: 'qm' },
    { name: 'Reporting', prefix: 'sr' },
    { name: 'RiskManagement', prefix: 'rk' },
    { name: 'ServicePack', prefix: 'sp' },
    { name: 'Store', prefix: 'st' },
    { name: 'RiskManagement', prefix: 'rm' },
    { name: 'SystemManager', prefix: 'sm' },
    { name: 'TankManagemet', prefix: 'tm' },
    { name: 'TaxForm', prefix: 'tf' },
    { name: 'Transports', prefix: 'tr' },
    { name: 'VendorRebates', prefix: 'vr' },
    { name: 'Warehouse', prefix: 'wh' }
];

var destDir = 'test/specs';
function getConfig(type) {
    return {
        type: type,
        moduleName: "Inventory",
        dependencyDir: "app/**/*.js",
        resolveModuleDependencies: true,
        aliasMappings: aliasMappings,
        destDir: destDir,
        formatContent: true,
        dependencyDestDir: "test/mock"    
    };
}

/**
 * ===================================================
 *            Generate Specs Asynchronuously
 * ===================================================
 */

gulp.task('spec-m', function() {
    return gulp.src('app/model/**/*.js')
        .pipe(gen(getConfig("model")))
        .pipe(gulp.dest(destDir));
});

gulp.task('spec-s', function() {
    return gulp.src('app/store/**/*.js')
        .pipe(gen(getConfig("store")))
        .pipe(gulp.dest(destDir));
});

gulp.task('spec-vc', function() {
    return gulp.src('app/view/**/*.js')
        .pipe(gen(getConfig("viewcontroller")))
        .pipe(gulp.dest(destDir));
});

gulp.task('spec-vm', function() {
    return gulp.src('app/view/**/*.js')
        .pipe(gen(getConfig("viewmodel")))
        .pipe(gulp.dest(destDir));
});

gulp.task("spec",["spec-m", "spec-s", "spec-vc", "spec-vm"]);

/**
 * ===================================================
 *            Generate Specs Synchronuously
 * ===================================================
 */
gulp.task('spec-s-sync', ['spec-m'], function() {
    return gulp.src('app/store/**/*.js')
        .pipe(gen(getConfig("store")))
        .pipe(gulp.dest(destDir));
});

gulp.task('spec-vc-sync', ['spec-s-sync'], function() {
    return gulp.src('app/view/**/*.js')
        .pipe(gen(getConfig("viewcontroller")))
        .pipe(gulp.dest(destDir));
});

gulp.task("spec-sync",["spec-vc-sync"]);