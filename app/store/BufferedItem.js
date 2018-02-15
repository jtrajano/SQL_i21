Ext.define('Inventory.store.BufferedItem', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbuffereditem',

    requires: [
        'Inventory.model.Item'
    ],

    model: 'Inventory.model.Item',
    storeId: 'BufferedItem',
    pageSize: 50,
    batchActions: true,
    remoteFilter: true,
    remoteSort: true,
    proxy: {
        type: 'rest',
        api: {
            read: './inventory/api/item/search'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});