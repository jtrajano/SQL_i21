Ext.define('Inventory.store.BufferedItemStockViewWithComments', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemstockviewwithcomments',
    requires: [
        'Inventory.model.ItemStockView'
    ],
    model: 'Inventory.model.ItemStockView',
    storeId: 'BufferedItemStockViewWithComments',
    pageSize: 50,
    batchActions: true,
    remoteFilter: true,
    remoteSort: true,
    proxy: {
        type: 'rest',
        api: {
            read: './inventory/api/item/searchitemstockswithcomments'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});