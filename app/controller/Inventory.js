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
    }
});
