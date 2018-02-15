Ext.define('Inventory.store.BufferedItemSubLocationsLookup', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
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
            read: './inventory/api/itemstock/getitemsublocations'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});