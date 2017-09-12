Ext.define('Inventory.store.LotHistory', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.iclothistory',

    requires: [
        'Inventory.model.LotHistory'
    ],

    model: 'Inventory.model.LotHistory',
    storeId: 'LotHistory',
    pageSize: 50,
    batchActions: true,
    proxy: {
        type: 'rest',
        api: {
            read: '../Inventory/api/Lot/GetHistory',
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