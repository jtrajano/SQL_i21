/**
 * Created by LZabala on 11/11/2014.
 */
Ext.define('Inventory.store.BufferedSeasonAttribute', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedseasonattribute',

    requires: [
        'Inventory.model.CommoditySeason'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CommoditySeason',
            storeId: 'BufferedSeasonAttribute',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CommodityAttribute/GetSeasonAttributes'
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