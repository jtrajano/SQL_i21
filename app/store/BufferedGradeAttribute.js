/**
 * Created by LZabala on 11/11/2014.
 */
Ext.define('Inventory.store.BufferedGradeAttribute', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedgradeattribute',

    requires: [
        'Inventory.model.CommodityGrade'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CommodityGrade',
            storeId: 'BufferedGradeAttribute',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CommodityAttribute/GetGradeAttributes'
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