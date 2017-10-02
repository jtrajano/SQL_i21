Ext.define('Inventory.store.M2MComputation', {
    extend: 'Ext.data.Store',
    alias: 'store.icm2mcomputation',

    requires: [
        'Inventory.model.M2MComputation'
    ],

    model: 'Inventory.model.M2MComputation',
    storeId: 'M2MComputation',
    pageSize: 50,
    batchActions: true,
    proxy: {
        type: 'rest',
        api: {
            read: './inventory/api/m2mcomputation/get',
            update: './inventory/api/m2mcomputation/put',
            create: './inventory/api/m2mcomputation/post',
            destroy: './inventory/api/m2mcomputation/delete'
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
