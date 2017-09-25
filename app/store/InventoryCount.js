/**
 * Created by LZabala on 10/22/2015.
 */
Ext.define('Inventory.store.InventoryCount', {
    extend: 'Ext.data.Store',
    alias: 'store.icinventorycount',

    requires: [
        'Inventory.model.InventoryCount'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.InventoryCount',
            storeId: 'InventoryCount',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../inventory/api/inventorycount/get',
                    update: '../inventory/api/inventorycount/put',
                    create: '../inventory/api/inventorycount/post',
                    destroy: '../inventory/api/inventorycount/delete'
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