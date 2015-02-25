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

    init: function() {
        Ext.Ajax.request({
            timeout: 120000,
            url: '../Inventory/api/Item/GetEmpty',
            method: 'GET'
        });
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

    getICAccountCategories: function() {
        var accounts = [
            {
                column: 'strAccountCategory',
                value: 'End Inventory',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Fee Expense',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Fee Income',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Freight Expenses',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Interest Expense',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Interest Income',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Inventory',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Options Expense',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Options Expense',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Options Income',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Purchase Account',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Rail Freight',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Sales Account',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Storage Expense',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Storage Income',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Begin Inventory',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Broker Expense',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Contract Equity',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Contract Purchase Gain/Loss',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Contract Sales Gain/Loss',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Cost of Goods',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Currency Equity',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Currency Purchase Gain/Loss',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Currency Sales Gain/Loss',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Discount Receivable',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'DP Income',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'DP Liability',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Storage Income',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Storage Receivable',
                conjunction: 'or'
            },
            {
                column: 'strAccountCategory',
                value: 'Variance Account',
                conjunction: 'or'
            }
        ];

        return accounts;
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
    }
});
