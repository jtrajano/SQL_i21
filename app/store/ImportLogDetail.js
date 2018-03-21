Ext.define('Inventory.store.ImportLogDetail', {
    extend: 'Ext.data.Store',
    alias: 'store.icimportlogDetail',

    requires: [
        'Inventory.model.ImportLogDetail'
    ],

    model: 'Inventory.model.ImportLogDetail',
    timeout: 120000,
    storeId: 'ImportLogDetail',
    pageSize: 50,
    remoteFilter: true,
    remoteSort: true,
    batchActions: true,
    proxy: {
        type: 'rest',
        api: {
            read: './inventory/api/importlogdetail/get',
            destroy: './inventory/api/importlogdetail/delete'
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