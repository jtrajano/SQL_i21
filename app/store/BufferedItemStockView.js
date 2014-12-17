/**
 * Created by LZabala on 11/25/2014.
 */
Ext.define('Inventory.store.BufferedItemStockView', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemstockview',

    requires: [
        'Inventory.model.ItemStockView'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemStockView',
            storeId: 'BufferedItemStockView',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/GetItemStocks'
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