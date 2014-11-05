/**
 * Created by LZabala on 10/30/2014.
 */
Ext.define('Inventory.model.LineOfBusiness', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intLineOfBusinessId',

    fields: [
        { name: 'intLineOfBusinessId', type: 'int'},
        { name: 'strLineOfBusiness', type: 'string'},
        { name: 'intSort', type: 'int'},
    ],

    validators: [
        {type: 'presence', field: 'strLineOfBusiness'}
    ]
});