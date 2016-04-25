/**
 * Created by WEstrada on 4/19/2016.
 */
Ext.define('Inventory.model.ReceiptItemView', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryReceiptItemId',

    fields: [
        { name: 'intInventoryReceiptId', type: 'int' },
        { name: 'intInventoryReceiptItemId', type: 'int' },
        { name: 'intItemId', type: 'int' },
        { name: 'dblReceived', type: 'float' },
        { name: 'dblBillQty', type: 'float' },
        { name: 'intSourceId', type: 'int' },
        { name: 'strOrderNumber', type: 'string' },
        { name: 'strSourceNumber', type: 'string' },
        { name: 'strSourceType', type: 'string' },
        { name: 'intRecordNo', type: 'int' }
    ]
});