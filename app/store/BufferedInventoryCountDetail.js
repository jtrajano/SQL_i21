Ext.define('Inventory.store.BufferedInventoryCountDetail', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedinventorycountdetail',

    requires: [
        'Inventory.model.InventoryCountDetail'
    ],

    model: 'Inventory.model.InventoryCountDetail',
    storeId: 'BufferedInventoryCountDetail',
    pageSize: 50,
    batchActions: true,
    remoteFilter: true,
    remoteSort: true,
    proxy: {
        type: 'rest',
        api: {
            read: '../Inventory/api/InventoryCount/GetInventoryCountDetails'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});