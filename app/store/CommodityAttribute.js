/**
 * Created by LZabala on 10/28/2014.
 */
Ext.define('Inventory.store.CommodityAttribute', {
    extend: 'Ext.data.Store',
    alias: 'store.iccommodityattribute',

    requires: [
        'Inventory.model.CommodityAttribute'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CommodityAttribute',
            storeId: 'CommodityAttribute',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CommodityAttribute/GetCommodityAttributes',
                    update: '../Inventory/api/CommodityAttribute/PutCommodityAttributes',
                    create: '../Inventory/api/CommodityAttribute/PostCommodityAttributes',
                    destroy: '../Inventory/api/CommodityAttribute/DeleteCommodityAttributes'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                },
                writer: {
                    type: 'json',
                    allowSingle: false
                }
            }
        }, cfg)]);
    }
});