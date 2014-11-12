/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedCategory', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedcategory',

    requires: [
        'Inventory.model.Category'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Category',
            storeId: 'BufferedCategory',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Category/GetCategories'
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