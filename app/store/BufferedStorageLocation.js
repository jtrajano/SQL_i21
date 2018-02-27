/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedStorageLocation', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedstoragelocation',

    requires: [
        'Inventory.model.StorageLocation'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.StorageLocation',
            storeId: 'BufferedStorageLocation',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/storagelocation/search'
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