/**
 * Created by LZabala on 11/3/2015.
 */
Ext.define('Inventory.store.ItemStockSummaryByLot', {
    extend: 'Ext.data.Store',
    alias: 'store.icitemstocksummarybylot',

    requires: [
        'Inventory.model.ItemStockSummary'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemStockSummary',
            storeId: 'ItemStockSummaryByLot',
            pageSize: 1000000,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/InventoryCount/GetItemStockSummaryByLot'
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