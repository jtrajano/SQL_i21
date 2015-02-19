/**
 * Created by LZabala on 12/17/2014.
 */
Ext.define('Inventory.model.Lot', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intLotId',

    fields: [
        { name: 'intLotId', type: 'int'},
        { name: 'strLotNumber', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strLotId'}
    ]
});