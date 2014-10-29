/**
 * Created by LZabala on 10/29/2014.
 */
Ext.define('Inventory.model.PackType', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.PackTypeDetail',
        'Ext.data.Field'
    ],

    idProperty: 'intPackTypeId',

    fields: [
        { name: 'intPackTypeId', type: 'int'},
        { name: 'strPackName', type: 'string'},
        { name: 'strDescription', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strPackName'}
    ]
});