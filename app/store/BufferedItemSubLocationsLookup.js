Ext.define('Inventory.store.BufferedItemSubLocationsLookup', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemsublocationslookup',

    requires: [
        'Inventory.model.ItemSubLocationsLookup'
    ],

    model: 'Inventory.model.ItemSubLocationsLookup',
    storeId: 'BufferedItemSubLocationsLookup',
    pageSize: 50,
    batchActions: true,
    remoteFilter: true,
    remoteSort: true,
    proxy: {
        type: 'rest',
        api: {
            read: '../Inventory/api/ItemStock/GetItemSubLocations'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});