/**
 * Created by LZabala on 10/10/2014.
 */
Ext.define('Inventory.model.ReceiptItemTax', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryReceiptItemTaxId',

    fields: [
        { name: 'intInventoryReceiptItemTaxId', type: 'int'},
        { name: 'intInventoryReceiptItemId', type: 'int'},
        { name: 'intTaxCodeId', type: 'int'},
        { name: 'ysnSelected', type: 'boolean'},
        { name: 'intSort', type: 'int'},
    ]
});