/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.ItemContractDocument', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemContractDocumentId',

    fields: [
        { name: 'intItemContractDocumentId', type: 'int'},
        { name: 'intItemContractId', type: 'int'},
        { name: 'intDocumentId', type: 'int'},
        { name: 'intSort', type: 'int'}
    ]
});