Ext.define('Inventory.store.BufferedItem', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditem',

    requires: [
        'Inventory.model.Item'
    ],

    model: 'Inventory.model.Brand',
    storeId: 'BufferedItem',
    pageSize: 50,
    batchActions: true,
    remoteFilter: true,
    remoteSort: true,
    proxy: {
        type: 'rest',
        api: {
            read: '../Inventory/api/Item/Search'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});