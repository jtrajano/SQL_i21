/**
 * Created by LZabala on 9/15/2014.
 */
Ext.define('Inventory.controller.Inventory', {
    extend: 'i21.controller.Module',
    alias: 'controller.inventory',
    requires: [
        'Inventory.Utils',
        'Inventory.ux.GridUOMColumn',
        'Inventory.ux.GridUOMField',
        'iRely.form.field.NumericField',
        'iRely.form.field.DateTimeField',
        'iRely.grid.CustomSummary',
        'GlobalComponentEngine.view.ActivityGrid',
        'GlobalComponentEngine.view.AttachmentGrid',
        'GlobalComponentEngine.view.AuditLogTree',
        'GlobalComponentEngine.view.AdvanceSearchGrid',
        'iRely.container.ImageContainer',
        'iRely.grid.Manager',
        'GeneralLedger.controls.AccountComboBox'
    ],
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

    /**
     * Creates the panel that is shown in the System Manager -> Origin Conversions
     */
    createUtilityUI: function(callback) {
        "use strict";
        iRely.Functions.createScreen('Inventory.view.OriginConversionOption', callback, { title: 'Inventory' });
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
        Ext.Loader.loadScript("../Inventory/app/lib/underscore.js");
        Ext.Loader.loadScript("../Inventory/app/lib/rx.all.js");
        Ext.Loader.loadScript("../Inventory/app/lib/numeraljs/numeral.js");
        
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

        if(record) {
            return record.get(field);
        }
        else {
            return null;
        }    
    },

    createPreferenceUI: function() {
        // If Cash Management will have a company preference, it must be implemented here.
        // Removed Ext.require here. It is not working very well on modem speeds.
        // Transferred it to the init functions of the screen controllers (e.g. BankAccountRegister, BankAccounts, and etc.)
    },

    createNumberFormat: function (precision) {
        return "0." + Ext.String.repeat('0', precision);
    },

    roundDecimalFormat: function(number, precision) {
        //return parseFloat(parseFloat(Math.round(number * 100) / 100).toFixed(precision));
        var zeroes = "";
        for(var i = 0; i < precision; i++) {
            zeroes += "0";
        }
        var pattern = "0.[" + zeroes + "]";
        return parseFloat(numeral(number).format(pattern));
    },

    roundDecimalValue: function(number, precision) {
        var factor = Math.pow(10, precision);
        var tempNumber = number * factor;
        var roundedTempNumber = Math.round(tempNumber);
        return roundedTempNumber / factor;
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
        shortUPC = shortUPC.toString();
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

    validateFullUPC: function(fullUPC) {
        if (iRely.Functions.isEmpty(fullUPC)) return null;
        fullUPC = fullUPC.toString();
        var finalUPC = fullUPC;
        if (fullUPC.length < 13) {
            finalUPC = Ext.String.repeat('0', 13 - fullUPC.length) + fullUPC + '0';
        }

        return finalUPC;
    },

    getShortUPCString: function(fullUPC) {
        if (iRely.Functions.isEmpty(fullUPC)) return null;
        fullUPC = fullUPC.toString();
        var shortUPC = '';

        if (fullUPC.length < 13) {
            fullUPC = this.validateFullUPC(fullUPC);
        }

        if (fullUPC.substring(8, 12) === '0000' && fullUPC.substring(12, 13) > 4) {
            shortUPC = fullUPC.substring(3, 8) + fullUPC.substring(12, 13);
        }
        if (fullUPC.substring(7, 12) === '00000') {
            shortUPC = fullUPC.substring(3, 7) + fullUPC.substring(12, 13) + '4';
        }
        if (fullUPC.substring(6, 11) === '00000') {
            shortUPC = fullUPC.substring(3, 6) + fullUPC.substring(11, 13) + '3';
        }
        if (fullUPC.substring(5, 10) === '00000') {
            shortUPC = fullUPC.substring(3, 5) + fullUPC.substring(10, 13) + '2';
        }
        if (fullUPC.substring(5, 10) === '10000') {
            shortUPC = fullUPC.substring(3, 5) + fullUPC.substring(10, 13) + '1';
        }
        if (fullUPC.substring(5, 10) === '00000') {
            shortUPC = fullUPC.substring(3, 5) + fullUPC.substring(10, 13) + '0';
        }

        var temp = this.trimNumber(fullUPC);
        temp = temp.toString().substring(0, 6);
        if (parseFloat(temp) > 99999) {
            
        }

        return shortUPC;
    },

    trimNumber: function (s) {
        while (s.substr(0, 1) == '0' && s.length > 1) {
            s = s.substr(1, s.length);
        }
        return s;
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

    showScreenFromHeaderDrilldown: function(screen, grid, fieldName) {
        var selections = [];
        var idList = '';

        if (grid) {
            if (grid.getSelectionModel()) {
                selections = grid.getSelectionModel().getSelection();
                for (var i = 0; i < selections.length; ++i) {
                    if (!selections[i].dummy) {
                        if (idList.toString().length > 0) idList += '|^|';
                        idList += selections[i].get(fieldName);
                    }
                }
            }
        }

        if (idList.length > 0) {
            iRely.Functions.openScreen(screen, idList);
        }
        else {
            iRely.Functions.openScreen(screen, { action: 'new', viewConfig: { modal: true }});
        }
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
            case 'ItemNo':
                screenName = 'Inventory.view.Item';
                columnName = 'strItemNo';
                break;
            case 'CategoryId':
                screenName = 'Inventory.view.Category';
                columnName = 'intCategoryId';
                break;
            case 'Category':
                screenName = 'Inventory.view.Category';
                columnName = 'strCategoryCode';
                break;
            case 'UOM':
                screenName = 'Inventory.view.InventoryUOM';
                columnName = 'strUnitMeasure';
                break;
            case 'Order':
                screenName = 'AccountsReceivable.view.SalesOrder';
                columnName = 'intSalesOrderId';
                break;
            case 'SONumber':
                screenName = 'AccountsReceivable.view.SalesOrder';
                columnName = 'strSalesOrderNumber';
                break;
            case 'PONumber':
                screenName = 'AccountsPayable.view.PurchaseOrder';
                columnName = 'strPurchaseOrderNumber';
                break;
            case 'ReceiptNo':
                screenName = 'Inventory.view.InventoryReceipt';
                columnName = 'strReceiptNumber';
                break;
            case 'ShipmentNo':
                screenName = 'Inventory.view.InventoryShipment';
                columnName = 'strShipmentNumber';
                break;
            case 'TransferNo':
                screenName = 'Inventory.view.InventoryTransfer';
                columnName = 'strTransferNo';
                break;
            case 'AdjustmentNo':
                screenName = 'Inventory.view.InventoryAdjustment';
                columnName = 'strAdjustmentNo';
                break;
            case 'VendorName':
                screenName = 'EntityManagement.view.Entity:searchEntityVendor';
                columnName = 'strName';
                break;
            case 'CustomerName':
                screenName = 'EntityManagement.view.Entity:searchEntityCustomer';
                columnName = 'strName';
                break;
            case 'LocationName':
                screenName = 'i21.view.CompanyLocation';
                columnName = 'strLocationName';
                break;
            case 'TaxGroup':
                screenName = 'i21.view.TaxGroup';
                columnName = 'strTaxGroup';
                break;
            case 'StorageLocation':
                screenName = 'Inventory.view.StorageUnit';
                columnName = 'strName';
                break;
            case 'LotStatus':
                screenName = 'Inventory.view.LotStatus';
                columnName = 'strSecondaryName';
                break;
            case 'CountGroup':
                screenName = 'Inventory.view.InventoryCountGroup';
                columnName = 'strCountGroup';
                break;
            case 'Commodity':
                screenName = 'Inventory.view.Commodity';
                columnName = 'strCommodityCode';
                break;
            case 'SubCategory':
                screenName = 'Store.view.SubCategory';
                columnName = 'strSubcategoryType';
                break;
            case 'ProductCode':
                screenName = 'Store.view.Store';
                columnName = 'strRegProdCode';
                break;
            case 'PromotionalItem':
                screenName = 'Store.view.PromotionSales';
                columnName = 'strPromoItemListId';
                break;
            case 'DepositPLU':
                screenName = 'Store.view.SubCategory';
                columnName = 'strSubcategoryType';
                break;
            case 'Invoice':
                screenName = 'AccountsReceivable.view.Invoice';
                columnName = 'strInvoiceNumber';
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
    },

    globalSearchSettings: function() {
        return [
            {
                screen: 'Inventory.view.InventoryReceipt',
                valueField: 'intInventoryReceiptId',
                displayField: 'strReceiptNumber',
                displayTitle: 'Inventory Receipt',
                screenIcon: 'maintenance',
                url: '../Inventory/api/InventoryReceipt/Search',
                fields: [
                    {name: 'intInventoryReceiptId', type: 'int'},
                    {name: 'strReceiptNumber', type: 'string'}
                ]
            },
            {
                screen: 'Inventory.view.InventoryReceipt',
                valueField: 'intInventoryReceiptId',
                displayField: 'strReceiptNumber',
                displayTitle: 'Inventory Receipt Details',
                screenIcon: 'maintenance',
                url: '../Inventory/api/InventoryReceipt/SearchReceiptItems',
                fields: [
                    {name: 'intInventoryReceiptId', type: 'int'},
                    {name: 'strReceiptNumber', type: 'string'},
                    {name: 'strReceiptType', type: 'string'}
                ]
            },
            {
                screen: 'Inventory.view.InventoryReceipt',
                valueField: 'intInventoryReceiptId',
                displayField: 'strReceiptNumber',
                displayTitle: 'Inventory Receipt Charges',
                screenIcon: 'maintenance',
                url: '../Inventory/api/InventoryReceipt/SearchReceiptCharges',
                fields: [
                    {name: 'intInventoryReceiptId', type: 'int'},
                    {name: 'strReceiptNumber', type: 'string'}
                ]
            },
            {
                screen: 'Inventory.view.InventoryReceipt',
                valueField: 'intInventoryReceiptId',
                displayField: 'strReceiptNumber',
                displayTitle: 'Inventory Receipt Lots',
                screenIcon: 'maintenance',
                url: '../Inventory/api/InventoryReceipt/SearchReceiptItemLots',
                fields: [
                    {name: 'intInventoryReceiptId', type: 'int'},
                    {name: 'strReceiptNumber', type: 'string'},
                    {name: 'strReceiptType', type: 'string'}
                ]
            },
            {
                screen: 'Inventory.view.InventoryReceipt',
                valueField: 'intInventoryReceiptId',
                displayField: 'strReceiptNumber',
                displayTitle: 'Inventory Receipt Vouchers',
                screenIcon: 'maintenance',
                url: '../Inventory/api/InventoryReceipt/SearchReceiptVouchers',
                fields: [
                    {name: 'intInventoryReceiptId', type: 'int'},
                    {name: 'strReceiptNumber', type: 'string'},
                    {name: 'strReceiptType', type: 'string'}
                ]
            },
            {
                screen: 'Inventory.view.InventoryShipment',
                valueField: 'intInventoryShipmentId',
                displayField: 'strShipmentNumber',
                displayTitle: 'Inventory Shipment',
                screenIcon: 'maintenance',
                url: '../Inventory/api/InventoryShipment/Search',
                fields: [
                    {name: 'intInventoryShipmentId', type: 'int'},
                    {name: 'strShipmentNumber', type: 'string'}
                ]
            },
            {
                screen: 'Inventory.view.InventoryShipment',
                valueField: 'intInventoryShipmentId',
                displayField: 'strShipmentNumber',
                displayTitle: 'Inventory Shipment Details',
                screenIcon: 'maintenance',
                url: '../Inventory/api/InventoryShipment/SearchShipmentItems',
                fields: [
                    {name: 'intInventoryShipmentId', type: 'int'},
                    {name: 'strShipmentNumber', type: 'string'}
                ]
            },
            {
                screen: 'Inventory.view.InventoryShipment',
                valueField: 'intInventoryShipmentId',
                displayField: 'strShipmentNumber',
                displayTitle: 'Inventory Shipment Lots',
                screenIcon: 'maintenance',
                url: '../Inventory/api/InventoryShipment/SearchShipmentItemLots',
                fields: [
                    {name: 'intInventoryShipmentId', type: 'int'},
                    {name: 'strShipmentNumber', type: 'string'}
                ]
            },
            {
                screen: 'Inventory.view.InventoryAdjustment',
                valueField: 'intInventoryAdjustmentId',
                displayField: 'strAdjustmentNo',
                displayTitle: 'Inventory Adjustment',
                screenIcon: 'maintenance',
                url: '../Inventory/api/InventoryAdjustment/Search',
                fields: [
                    {name: 'intInventoryShipmentId', type: 'int'},
                    {name: 'strAdjustmentNo', type: 'string'},
                    {name: 'strAdjustmentType', type: 'string'}
                ]
            },
            {
                screen: 'Inventory.view.InventoryAdjustment',
                valueField: 'intInventoryAdjustmentDetailId',
                displayField: 'strAdjustmentNo',
                displayTitle: 'Inventory Adjustment Details',
                screenIcon: 'maintenance',
                url: '../Inventory/api/InventoryAdjustment/SearchAdjustmentDetails',
                fields: [
                    {name: 'intInventoryAdjustmentDetailId', type: 'int'},
                    {name: 'intInventoryShipmentId', type: 'int'},
                    {name: 'strAdjustmentNo', type: 'string'},
                    {name: 'strAdjustmentType', type: 'string'}
                ]
            },
            {
                screen: 'Inventory.view.Item',
                valueField: 'intItemId',
                displayField: 'strItemNo',
                displayTitle: 'Item',
                screenIcon: 'maintenance',
                url: '../Inventory/api/Item/Search',
                fields: [
                    {name: 'intItemId', type: 'int'},
                    {name: 'strItemNo', type: 'string'},
                    {name: 'strType', type: 'string'}
                ]
            },
            {
                screen: 'Inventory.view.Item',
                valueField: 'intItemId',
                displayField: 'strItemNo',
                displayTitle: 'Item Locations',
                screenIcon: 'maintenance',
                url: '../Inventory/api/ItemLocation/SearchItemLocationViews',
                fields: [
                    {name: 'intItemId', type: 'int'},
                    {name: 'strItemNo', type: 'string'},
                ]
            },
            {
                screen: 'Inventory.view.Item',
                valueField: 'intItemId',
                displayField: 'strItemNo',
                displayTitle: 'Item Pricing',
                screenIcon: 'maintenance',
                url: '../Inventory/api/ItemPricing/SearchItemPricingViews',
                fields: [
                    {name: 'intItemId', type: 'int'},
                    {name: 'strItemNo', type: 'string'}
                ]
            }
        ]
    }
});
