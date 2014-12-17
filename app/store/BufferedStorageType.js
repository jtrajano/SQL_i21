/**
 * Created by LZabala on 11/6/2014.
 */
Ext.define('Inventory.store.BufferedStorageType', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedstoragetype',

    requires: [
        'Inventory.model.StorageType'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.StorageType',
            storeId: 'BufferedStorageType',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/StorageType/GetStorageTypes',
                    update: '../Inventory/api/StorageType/PutStorageTypes',
                    create: '../Inventory/api/StorageType/PostStorageTypes',
                    destroy: '../Inventory/api/StorageType/DeleteStorageTypes'
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
        }, cfg)]);
    }
});