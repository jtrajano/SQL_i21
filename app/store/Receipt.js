/**
 * Created by LZabala on 10/10/2014.
 */
Ext.define('Inventory.store.Receipt', {
    extend: 'Ext.data.Store',
    alias: 'store.inventoryreceipt',

    requires: [
        'Inventory.model.Receipt'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Receipt',
            storeId: 'Receipt',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Receipt/GetReceipts',
                    update: '../Inventory/api/Receipt/PutReceipts',
                    create: '../Inventory/api/Receipt/PostReceipts',
                    destroy: '../Inventory/api/Receipt/DeleteReceipts'
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