Ext.define('Inventory.store.ImportLog', {
    extend: 'Ext.data.Store',
    alias: 'store.icimportlog',

    requires: [
        'Inventory.model.ImportLog'
    ],

    model: 'Inventory.model.ImportLog',
    timeout: 120000,
    storeId: 'ImportLog',
    pageSize: 50,
    remoteFilter: true,
    remoteSort: true,
    batchActions: true,
    proxy: {
        type: 'rest',
        api: {
            read: './inventory/api/importlog/get',
            destroy: './inventory/api/importlog/delete'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            allowSingle: false
        }
    }
});