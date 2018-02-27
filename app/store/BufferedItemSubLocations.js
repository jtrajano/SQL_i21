/**
 * Created by FMontefrio on 02/27/2017.
 */
Ext.define('Inventory.store.BufferedItemSubLocations', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemsublocations',

    requires: [
        'Inventory.model.ItemSubLocation'
    ],

    model: 'Inventory.model.ItemSubLocation',
    storeId: 'BufferedItemSubLocationsStore',
    pageSize: 50,
    batchActions: true,
    remoteFilter: true,
    remoteSort: true,
    proxy: {
        type: 'rest',
        api: {
            read: './inventory/api/item/searchitemsublocations'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});