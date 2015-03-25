/**
 * Created by LZabala on 11/14/2014.
 */
Ext.define('Inventory.store.BufferedItemWeightUOM', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemweightuom',

    requires: [
        'Inventory.model.ItemUOM'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemUOM',
            storeId: 'BufferedItemWeightUOM',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/ItemUnitMeasure/GetWeightUOMs'
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