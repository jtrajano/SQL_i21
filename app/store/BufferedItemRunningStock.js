Ext.define('Inventory.store.BufferedItemRunningStock', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemrunningstock',

    requires: [
        'Inventory.model.ItemRunningStock'
    ],


    model: 'Inventory.model.ItemRunningStock',
    storeId: 'BufferedItemRunningStock',
    pageSize: 50,
    batchActions: true,
    remoteFilter: true,
    remoteSort: true,
    proxy: {
        type: 'rest',
        api: {
            read: './inventory/api/item/getitemrunningstock'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});