/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedPatronageCategory', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedpatronagecategory',

    requires: [
        'Inventory.model.PatronageCategory'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.PatronageCategory',
            storeId: 'BufferedPatronageCategory',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/PatronageCategory/GetPatronageCategories'
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
