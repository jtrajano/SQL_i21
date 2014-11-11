/**
 * Created by LZabala on 11/11/2014.
 */
Ext.define('Inventory.store.BufferedRegionAttribute', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedregionattribute',

    requires: [
        'Inventory.model.CommodityRegion'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CommodityRegion',
            storeId: 'BufferedRegionAttribute',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CommodityAttribute/GetRegionAttributes'
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