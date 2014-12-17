/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedProcessCode', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedprocesscode',

    requires: [
        'Inventory.model.ProcessCode'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ProcessCode',
            storeId: 'BufferedProcessCode',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/RinProcess/GetRinProcesses'
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
