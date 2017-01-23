Ext.define('Inventory.store.LotDetailHistory', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.iclotdetailhistory',

    requires: [
        'Inventory.model.LotDetailHistory'
    ],

    model: 'Inventory.model.LotDetailHistory',
    storeId: 'LotDetailHistory',
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