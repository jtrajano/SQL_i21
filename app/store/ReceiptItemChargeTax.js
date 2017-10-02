/**
 * Created by JBalangatan on 10/12/2016.
 */
Ext.define('Inventory.store.ReceiptChargeTax', {
    extend: 'Ext.data.Store',
    alias: 'store.icreceiptchargetax',

    requires: [
        'Inventory.model.ReceiptChargeTax'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ReceiptChargeTax',
            storeId: 'ReceiptItemTax',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/inventoryreceiptchargetax/getreceiptchargetaxview',
                    update: './inventory/api/inventoryreceiptchargetax/put',
                    create: './inventory/api/inventoryreceiptchargetax/post',
                    destroy: './inventory/api/inventoryreceiptchargetax/delete'
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