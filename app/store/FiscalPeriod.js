Ext.define('Inventory.store.FiscalPeriod', {
    extend: 'Ext.data.Store',
    alias: 'store.icfiscalperiod',

    requires: [
        'Inventory.model.FiscalPeriod'
    ],

    model: 'Inventory.model.FiscalPeriod',
    storeId: 'FiscalPeriod',
    pageSize: 50,
    batchActions: true,
    proxy: {
        type: 'rest',
        api: {
            read: './inventory/api/inventoryvaluation/getfiscalmonths'
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
