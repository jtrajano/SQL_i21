/**
 * Created by LZabala on 9/10/2014.
 */
// Pause the karma loading.
window.__karma__.loaded = function(){}; // Assign an empty function.

// @require @packageOverrides
Ext.Loader.setConfig({
    enabled: true,
    paths: {
        'Ext.ux': 'resources/js/ux',
        'Ext.iux': 'resources/js/iux',
        i21: 'SystemManager/app',
        Dashboard: 'Dashboard/app',
        SystemManager: 'SystemManager/app',
        GeneralLedger: 'GeneralLedger/app',
        FinancialReportDesigner: 'FinancialReportDesigner/app',
        TankManagement: 'TankManagement/app',
        Reports: 'Reports/app',
        GlobalComponentEngine: 'GlobalComponentEngine/app',
        iRely: 'GlobalComponentEngine/irely',
        'SystemManager.api': 'SystemManager/api',
        'GeneralLedger.api': 'GeneralLedger/api',
        'FinancialReportDesigner.api': 'FinancialReportDesigner/api',
        'TankManagement.api': 'TankManagement/api',
        'Reporting.api': 'Reporting/api',
        'Mz.pivot': 'resources/js/ux/mzPivotGrid/pivot',
        AccountsReceivable: 'AccountsReceivable/app',
        CashManagement: 'CashManagement/app',
        'CashManagement.api': 'CashManagement/api',
        AccountsPayable: 'AccountsPayable/app',
        Deft: 'resources/js/deft',
        CustomerPortal: 'CustomerPortal/app',
        'CustomerPortal.api': 'CustomerPortal/api',
        HelpDesk: 'HelpDesk/app',
        'HelpDesk.api': 'HelpDesk/api',
        Payroll: 'Payroll/app',
        'Payroll.api': 'Payroll/api',
        Inventory: 'Inventory/app',
        'Inventory.api': 'Inventory/api'
    }
});

//noinspection JSHint
var app;

Ext.application({
    requires: [
        'Ext.Loader'
    ],
    name: 'i21',
    launch: function() {
        //noinspection JSHint
        app = this;

        Ext.onReady(function(){
            // Wait for Ext to be ready before running the karma test suite.
            window.__karma__.start();
        });
    }

});