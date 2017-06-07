Ext.define('Inventory.store.BufferedInventoryCountDetail', {
    extend: 'Ext.data.Store',
    alias: 'store.icbufferedinventorycountdetail',

    requires: [
        'Inventory.model.InventoryCountDetail'
    ],

    model: 'Inventory.model.InventoryCountDetail',
    storeId: 'BufferedInventoryCountDetail',
    pageSize: 200,
    batchActions: true,
    remoteFilter: true,
    // buffered: true,
    // leadingBufferZone: 700,
    remoteSort: true,
    proxy: {
        type: 'rest',
        api: {
            create: '../Inventory/api/InventoryCountDetail/Post',
            read: '../Inventory/api/InventoryCount/GetInventoryCountDetails',
            update: '../Inventory/api/InventoryCountDetail/UpdateDetail',
            destroy: '../Inventory/api/InventoryCountDetail/Delete',
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});