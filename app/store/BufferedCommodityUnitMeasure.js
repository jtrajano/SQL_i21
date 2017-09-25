/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedCommodityUnitMeasure', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedcommodityunitmeasure',

    requires: [
        'Inventory.model.CommodityUnitMeasure'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CommodityUnitMeasure',
            storeId: 'BufferedCommodityUnitMeasure',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../inventory/api/commodityuom/search'
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