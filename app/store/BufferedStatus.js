/**
 * Created by LZabala on 5/5/2015.
 */
Ext.define('Inventory.store.BufferedStatus', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedstatus',

    requires: [
        'Inventory.model.Status'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Status',
            storeId: 'BufferedStatus',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Status/Get'
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