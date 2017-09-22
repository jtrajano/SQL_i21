Ext.define('Inventory.store.BufferedItemStorageLocationsLookup', {
    extend: 'Ext.data.BufferedStore',
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
            read: '../Inventory/api/ItemStock/GetItemStorageLocations'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});