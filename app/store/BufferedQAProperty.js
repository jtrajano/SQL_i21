/**
 * Created by LZabala on 12/16/2014.
 */
Ext.define('Inventory.store.BufferedQAProperty', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedqaproperty',

    requires: [
        'Inventory.model.QAProperty'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.QAProperty',
            storeId: 'BufferedQAProperty',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/QAProperty/GetQAProperties'
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