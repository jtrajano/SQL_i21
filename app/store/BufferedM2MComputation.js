Ext.define('Inventory.store.BufferedM2MComputation', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedm2mcomputation',

    requires: [
        'Inventory.model.M2MComputation'
    ],

    model: 'Inventory.model.M2MComputation',
    storeId: 'BufferedM2MComputation',
    pageSize: 50,
    batchActions: true,

    proxy: {
        type: 'rest',
        api: {
            read: './inventory/api/m2mcomputation/search'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});