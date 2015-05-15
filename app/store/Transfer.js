/**
 * Created by LZabala on 4/16/2015.
 */
Ext.define('Inventory.store.Transfer', {
    extend: 'Ext.data.Store',
    alias: 'store.ictransfer',

    requires: [
        'Inventory.model.Transfer'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Transfer',
            storeId: 'Transfer',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/InventoryTransfer/Get',
                    update: '../Inventory/api/InventoryTransfer/Put',
                    create: '../Inventory/api/InventoryTransfer/Post',
                    destroy: '../Inventory/api/InventoryTransfer/Delete'
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