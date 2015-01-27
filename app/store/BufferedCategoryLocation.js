/**
 * Created by LZabala on 1/27/2015.
 */
Ext.define('Inventory.store.BufferedCategoryLocation', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedcategorylocation',

    requires: [
        'Inventory.model.CategoryLocation'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CategoryLocation',
            storeId: 'BufferedCategoryLocation',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CategoryLocation/GetCategoryLocations'
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