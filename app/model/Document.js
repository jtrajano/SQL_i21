/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.Document', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intDocumentId',

    fields: [
        { name: 'intDocumentId', type: 'int'},
        { name: 'strDocumentName', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intCommodityId', type: 'int', allowNull: true},
        { name: 'ysnStandard', type: 'boolean'},

        { name: 'strCommodityCode', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strDocumentName'},
        {type: 'presence', field: 'intCommodityId'}
    ]
});