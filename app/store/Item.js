/**
 * Created by LZabala on 9/11/2014.
 */
Ext.define('Inventory.store.Item', {
    extend: 'Ext.data.Store',
    alias: 'store.inventoryitem',

    requires: [
        'Inventory.model.Item'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Item',
            timeout: 120000,
            storeId: 'Item',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/GetItems',
                    update: '../Inventory/api/Item/PutItems',
                    create: '../Inventory/api/Item/PostItems',
                    destroy: '../Inventory/api/Item/DeleteItems'
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