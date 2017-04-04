/**
 * Created by LZabala on 11/3/2015.
 */
Ext.define('Inventory.store.BufferedItemStockSummary', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemstocksummary',

    requires: [
        'Inventory.model.ItemStockSummary'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemStockSummary',
            storeId: 'BufferedItemStockSummary',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/InventoryCount/SearchItemStockSummary'
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