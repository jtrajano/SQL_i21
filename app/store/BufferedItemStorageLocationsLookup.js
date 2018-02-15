Ext.define('Inventory.store.BufferedItemStorageLocationsLookup', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbuffereditemstoragelocationslookup',

    requires: [
        'Inventory.model.ItemStorageLocationsLookup'
    ],

    model: 'Inventory.model.ItemStorageLocationsLookup',
    storeId: 'BufferedItemStorageLocationsLookup',
    pageSize: 50,
    batchActions: true,
    remoteFilter: true,
    remoteSort: true,
    proxy: {
        type: 'rest',
        api: {
            read: './inventory/api/itemstock/getitemstoragelocations'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});