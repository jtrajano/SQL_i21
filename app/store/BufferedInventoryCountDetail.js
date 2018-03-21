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
        actionMethods: {
            create: 'POST',
            read: 'GET',
            update: 'PATCH',
            destroy: 'DELETE'
        },
        api: {
            create: './inventory/api/inventorycountdetail/post',
            read: './inventory/api/inventorycount/getinventorycountdetails',
            update: './inventory/api/inventorycountdetail/updatedetail',
            destroy: './inventory/api/inventorycountdetail/deletedetail',
        },
        writer: { writeAllFields: true },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});