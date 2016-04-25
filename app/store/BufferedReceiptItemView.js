/**
 * Created by WEstrada on 4/19/2016.
 */
Ext.define('Inventory.store.BufferedReceiptItemView', {
    extend: 'Ext.data.Store',
    alias: 'store.icbufferedreceiptitemview',

    requires: [
        'Inventory.model.ReceiptItemView'
    ],

    model: 'Inventory.model.ReceiptItemView',
    storeId: 'BufferedReceiptItemView',
    pageSize: 50,
    proxy: {
        type: 'rest',
        api: {
            read: '../Inventory/api/InventoryReceipt/SearchReceiptItemView'
        },
        extraParams: {
            intInventoryReceiptId: 156
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        }
    }
});