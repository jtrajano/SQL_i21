/**
 * Created by LZabala on 1/27/2015.
 */
Ext.define('Inventory.store.BufferedCategoryAccount', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedcategoryaccount',

    requires: [
        'Inventory.model.CategoryAccount'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CategoryAccount',
            storeId: 'BufferedCategoryAccount',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CategoryAccount/GetCategoryAccounts'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        }, cfg)]);
    }
});