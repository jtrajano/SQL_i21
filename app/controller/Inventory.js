/**
 * Created by LZabala on 9/15/2014.
 */
Ext.define('Inventory.controller.Inventory', {
    extend: 'i21.controller.Module',
    alias: 'controller.inventory',

    singleton: true,

    moduleName: 'Inventory',
    controllers: [
//        'i21.controller.LicenseRegistration',
//        'i21.controller.UserRole',
//        'i21.controller.UserSecurity',
//        'i21.controller.DatabaseConnection',
//        'i21.controller.ImportLegacyCompanies',
//        'i21.controller.ImportLegacyUsers',
//        'i21.controller.ImportLegacyMenus',
//        'i21.controller.MasterMenu',
//        'i21.controller.UserProfile',
//        'i21.controller.CompanyPreferences',
//        'i21.controller.Country',
//        'i21.controller.ZipCode',
//        'i21.controller.Currency',
//        'i21.controller.ZipCode',
//        'i21.controller.StartingNumbers',
//        'i21.controller.Term',
//        'i21.controller.PaymentMethod',
//        'i21.controller.ShipVia',
//        'i21.controller.OriginUtility',
//        'i21.controller.SecurityListingGenerator',
//        'i21.controller.EndUserLicenseAgreement',
//        'i21.controller.CompanyLocation'
    ],

    constructor: function () {
        this.superclass.constructor.call(this);
    },

    ICTransactionDrillDown: function(params) {
        var me = this,
            form = params[0].strTransactionForm,
            filterField,
            viewName,
            filter = [];

        switch(form){
            case 'Inventory Receipt':
                filterField = 'intInventoryReceiptId';
                viewName = 'Inventory.view.InventoryReceipt';
                break;
            case 'Inventory Adjustment':
                filterField = 'intInventoryAdjustmentId';
                viewName = 'Inventory.view.InventoryAdjustment';
                break;
            case 'Build Assembly':
                filterField = 'intBuildAssemblyId';
                viewName = 'Inventory.view.BuildAssemblyBlend';
                break;
            case 'Inventory Transfer':
                filterField = 'intInventoryTransferId';
                viewName = 'Inventory.view.InventoryTransfer';
                break;
            case 'Inventory Shipment':
                filterField = 'intInventoryShipmentId';
                viewName = 'Inventory.view.InventoryShipment';
                break;
        }

        Ext.each(params, function(param, index) {
            filter.push({
                column : filterField,
                value : params[index].intTransactionId,
                condition : 'eq',
                conjunction : 'Or'
            });
        });

        iRely.Functions.openScreen(viewName, { filters: filter });
    },

    init: function() {
        Ext.Ajax.request({
            timeout: 120000,
            url: '../Inventory/api/Item/GetEmpty',
            method: 'GET'
        });

        this.companyPreferenceStore = Ext.create('Inventory.store.CompanyPreference');
        this.companyPreferenceStore.load();
    },

    getCompanyPreference: function(field) {
        var me = this,
            record = me.companyPreferenceStore.getAt(0);

        return record.get(field);
    },

    createNumberFormat: function (precision) {
        return "0." + Ext.String.repeat('0', precision);
    },

    roundDecimalFormat: function(number, precision) {
        return parseFloat(Math.round(number * 100) / 100).toFixed(precision);
    },

    getTodayDate: function() {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();

        mm = mm - 1;

        today = new Date(yyyy, mm, dd, 1, 0, 0, 0);

        return today;
    },

    getFullUPCString: function(shortUPC) {
        if (iRely.Functions.isEmpty(shortUPC)) return null;
        if (shortUPC.length < 6) return null;
        var lastDigit = parseInt(shortUPC.toString().substring(shortUPC.length - 1));
        var fullUPC = "";
        if (lastDigit < 0 || lastDigit === null || lastDigit === undefined) return null;

        switch (lastDigit) {
            case 0 :
                fullUPC += "000";
                fullUPC += shortUPC.toString().substring(0, 2);
                fullUPC += "00000";
                fullUPC += shortUPC.toString().substring(2, 5);
                fullUPC += "0";
                break;
            case 1 :
                fullUPC += "000";
                fullUPC += shortUPC.toString().substring(0, 2);
                fullUPC += "10000";
                fullUPC += shortUPC.toString().substring(2, 5);
                fullUPC += "0";
                break;
            case 2 :
                fullUPC += "000";
                fullUPC += shortUPC.toString().substring(0, 2);
                fullUPC += "20000";
                fullUPC += shortUPC.toString().substring(2, 5);
                fullUPC += "0";
                break;
            case 3 :
                fullUPC += "000";
                fullUPC += shortUPC.toString().substring(0, 3);
                fullUPC += "00000";
                fullUPC += shortUPC.toString().substring(3, 5);
                fullUPC += "0";
                break;
            case 4 :
                fullUPC += "000";
                fullUPC += shortUPC.toString().substring(0, 4);
                fullUPC += "00000";
                fullUPC += shortUPC.toString().substring(4, 5);
                fullUPC += "0";
                break;
            default :
                fullUPC += "000";
                fullUPC += shortUPC.toString().substring(0, 5);
                fullUPC += "0000";
                fullUPC += shortUPC.toString().substring(5, 6);
                fullUPC += "0";
                break;
        }

        return fullUPC;
    },

    checkEmptyStore: function(arrayItems) {
        if (arrayItems.length > 0) {
            if (arrayItems.length === 1) {
                if (arrayItems[0].dummy) {
                    return true;
                }
                else {
                    return false;
                }
            }
            else
                return false;
        }
        else
            return true;
    },

    showScreen: function(recordId, screenType) {
        var screenName = '',
            action = 'new',
            columnName = '';

        switch (screenType) {
            case 'ItemId':
                screenName = 'Inventory.view.Item';
                columnName = 'intItemId';
                break;
            case 'CategoryId':
                screenName = 'Inventory.view.Category';
                columnName = 'intCategoryId';
                break;
            case 'Order':
                screenName = 'AccountsReceivable.view.SalesOrder';
                columnName = 'intSalesOrderId';
                break;
            case 'ReceiptNo':
                screenName = 'Inventory.view.InventoryReceipt';
                columnName = 'strReceiptNumber';
                break;
            case 'ShipmentNo':
                screenName = 'Inventory.view.InventoryShipment';
                columnName = 'strShipmentNumber';
                break;
            case 'VendorName':
            case 'CustomerName':
                screenName = 'EntityManagement.view.Entity';
                columnName = 'strName';
                break;
            case 'LocationName':
                screenName = 'i21.view.CompanyLocation';
                columnName = 'strLocationName';
                break;
        }

        var filter = [];
        if (recordId != 0 && recordId != 'undefined' && recordId) {
            action = 'view';
            filter.push({
                column: columnName,
                value: recordId,
                condition: 'eq',
                conjunction: ''
            });
        }

        if (screenName != '') {
            iRely.Functions.openScreen(screenName, {
                modalMode: true,
                action: action,
                filters: filter
            });
        }
    },

    computeDateAdd: function(currentDate, qty, type) {
        if (!currentDate) return;
        if (!qty) return;
        if (!type) return;
        var newDate = currentDate;

        switch (type) {
            case 'Minutes':
                newDate = Ext.Date.add(currentDate, Ext.Date.MINUTE, qty);
                break;
            case 'Hours':
                newDate = Ext.Date.add(currentDate, Ext.Date.HOUR, qty);
                break;
            case 'Days':
                newDate = Ext.Date.add(currentDate, Ext.Date.DAY, qty);
                break;
            case 'Months':
                newDate = Ext.Date.add(currentDate, Ext.Date.MONTH, qty);
                break;
            case 'Years':
                newDate = Ext.Date.add(currentDate, Ext.Date.YEAR, qty);
                break;
        }
        return newDate;
    }
});
