/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedStorageUnitType', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbufferedstorageunittype',

    requires: [
        'Inventory.model.StorageUnitType'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.StorageUnitType',
            storeId: 'BufferedStorageUnitType',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/storageunittype/search'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        }, cfg)]);
    }
});
