/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedLotStatus', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedlotstatus',

    requires: [
        'Inventory.model.LotStatus'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.LotStatus',
            storeId: 'BufferedLotStatus',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/LotStatus/GetLotStatuses'
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