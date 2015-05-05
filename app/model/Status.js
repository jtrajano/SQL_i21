/**
 * Created by LZabala on 5/5/2015.
 */
Ext.define('Inventory.model.Status', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intStatusId',

    fields: [
        { name: 'intStatusId', type: 'int'},
        { name: 'strStatus', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strStatus'}
    ]
});