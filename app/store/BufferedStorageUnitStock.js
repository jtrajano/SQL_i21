Ext.define('Inventory.store.BufferedStorageUnitStock', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbufferedstorageunitstock',

    requires: [
        'Inventory.model.StorageUnitStock'
    ],

    model: 'Inventory.model.StorageUnitStock',
    storeId: 'BufferedStorageUnitStock',
    pageSize: 50,
    batchActions: true,
    remoteFilter: true,
    remoteSort: true,
    proxy: {
        type: 'rest',
        api: {
            read: './inventory/api/storagelocation/getstorageunitstock'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});