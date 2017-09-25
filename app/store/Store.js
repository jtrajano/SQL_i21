/**
 * Created by LZabala on 11/4/2014.
 */
Ext.define('Inventory.store.Store', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.storestore',

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            fields: [
                { name: 'intStoreId', type: 'int'},
                { name: 'intStoreNo', type: 'int'},
                { name: 'strStoreName', type: 'boolean'},
                { name: 'StrDescription', type: 'boolean'},
                { name: 'strRegion', type: 'boolean'}
            ],
            storeId: 'Store',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../inventory/api/store/getstores'
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