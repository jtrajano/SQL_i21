/**
 * Created by FMontefrio on 12/10/2015.
 */
Ext.define('Inventory.model.ParentLot', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intParentLotId',

    fields: [
        { name: 'intParentLotId', type: 'int'},
        { name: 'intItemId', type: 'int'},
        { name: 'strParentLotNumber', type: 'string', auditKey: true},
        { name: 'strParentLotAlias', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strParentLotNumber'}
    ]
});