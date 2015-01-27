/**
 * Created by LZabala on 1/27/2015.
 */
Ext.define('Inventory.store.BufferedCategoryVendor', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedcategoryvendor',

    requires: [
        'Inventory.model.CategoryVendor'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CategoryVendor',
            storeId: 'BufferedCategoryVendor',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CategoryVendor/GetCategoryVendors'
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