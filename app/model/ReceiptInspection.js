/**
 * Created by LZabala on 10/10/2014.
 */
Ext.define('Inventory.model.ReceiptInspection', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryReceiptInspectionId',

    fields: [
        { name: 'intInventoryReceiptInspectionId', type: 'int'},
        { name: 'intInventoryReceiptId', type: 'int'},
        { name: 'intQAPropertyId', type: 'int'},
        { name: 'ysnSelected', type: 'boolean'},
        { name: 'intSort', type: 'int'}
    ]
});