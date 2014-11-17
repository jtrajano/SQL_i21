/**
 * Created by marahman on 18-09-2014.
 */
Ext.define('Inventory.model.FuelCategory', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intRinFuelCategoryId',

    fields: [
        { name: 'intRinFuelCategoryId', type: 'int'},
        { name: 'strRinFuelCategoryCode', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'strEquivalenceValue', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strRinFuelCategoryCode'}
    ]
});
