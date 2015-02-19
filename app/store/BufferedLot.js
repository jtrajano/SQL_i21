/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedLot', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedlot',

    requires: [
        'Inventory.model.Lot'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Lot',
            storeId: 'BufferedLot',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Lot/GetLots'
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