/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedStorageUnitType', {
    extend: 'Ext.data.BufferedStore',
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
                    read: '../Inventory/api/StorageUnitType/Search'
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
