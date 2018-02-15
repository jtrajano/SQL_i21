Ext.define('Inventory.store.BufferedSearchLot', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbufferedsearchlot',
    requires: [
        'Inventory.model.Lot'
    ],
    model: 'Inventory.model.Lot',
    storeId: 'BufferedSearchLot',
    pageSize: 50,
    batchActions: true,
    remoteFilter: true,
    remoteSort: true,
    proxy: {
        type: 'rest',
        api: {
            read: './inventory/api/lot/searchlots'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});