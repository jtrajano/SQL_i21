/**
 * Created by marahman on 18-09-2014.
 */
Ext.define('Inventory.model.FuelCode', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intRinFuelId',

    fields: [
        { name: 'intRinFuelId', type: 'int'},
        { name: 'strRinFuelCode', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validations: [
        {type: 'presence', field: 'strRinFuelCode'}
    ]
});
