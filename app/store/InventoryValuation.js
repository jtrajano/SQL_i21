/**
 * Created by LZabala on 9/18/2015.
 */
Ext.define('Inventory.store.InventoryValuation', {
    extend: 'Ext.data.Store',
    alias: 'store.icinventoryvaluation',

    requires: [
        'Inventory.model.InventoryValuation'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.InventoryValuation',
            storeId: 'InventoryValuation',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/GetInventoryValuation'
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