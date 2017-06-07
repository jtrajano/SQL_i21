Ext.define('Inventory.store.BufferedItemStockSummaryByLot', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemstocksummary',

    requires: [
        'Inventory.model.ItemStockSummary'
    ],

    model: 'Inventory.model.ItemStockSummary',
    storeId: 'BufferedItemStockSummary',
    pageSize: 50,
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
});