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
            read: '../Inventory/api/M2MComputation/Get',
            update: '../Inventory/api/M2MComputation/Put',
            create: '../Inventory/api/M2MComputation/Post',
            destroy: '../Inventory/api/M2MComputation/Delete'
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
