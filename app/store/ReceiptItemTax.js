/**
 * Created by LZabala on 10/10/2014.
 */
Ext.define('Inventory.store.ReceiptItemTax', {
    extend: 'Ext.data.Store',
    alias: 'store.icreceiptitemtax',

    requires: [
        'Inventory.model.ReceiptItemTax'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ReceiptItemTax',
            storeId: 'ReceiptItemTax',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/inventoryreceiptitemtax/getreceiptitemtaxview',
                    update: './inventory/api/inventoryreceiptitemtax/put',
                    create: './inventory/api/inventoryreceiptitemtax/post',
                    destroy: './inventory/api/inventoryreceiptitemtax/delete'
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