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
                    read: '../Inventory/api/ReceiptItemTax/GetReceiptItemTaxes',
                    update: '../Inventory/api/ReceiptItemTax/PutReceiptItemTaxes',
                    create: '../Inventory/api/ReceiptItemTax/PostReceiptItemTaxes',
                    destroy: '../Inventory/api/ReceiptItemTax/DeleteReceiptItemTaxes'
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