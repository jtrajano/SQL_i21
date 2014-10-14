/**
 * Created by marahman on 18-09-2014.
 */
Ext.define('Inventory.model.FuelCategory', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intRinFuelTypeId',

    fields: [
        { name: 'intRinFuelTypeId', type: 'int'},
        { name: 'strRinFuelTypeCode', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'dblEquivalenceValue', type: 'float'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strRinFuelTypeCode'}
    ]
});
