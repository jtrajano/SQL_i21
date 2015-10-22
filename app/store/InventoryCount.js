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
                    read: '../Inventory/api/InventoryCount/Get',
                    update: '../Inventory/api/InventoryCount/Put',
                    create: '../Inventory/api/InventoryCount/Post',
                    destroy: '../Inventory/api/InventoryCount/Delete'
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