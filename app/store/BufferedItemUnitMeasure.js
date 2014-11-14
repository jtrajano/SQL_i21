/**
 * Created by LZabala on 11/14/2014.
 */
Ext.define('Inventory.store.BufferedItemUnitMeasure', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybuffereditemunitmeasure',

    requires: [
        'Inventory.model.ItemUOM'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemUOM',
            storeId: 'BufferedItemUnitMeasure',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/ItemUnitMeasure/GetItemUnitMeasures'
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