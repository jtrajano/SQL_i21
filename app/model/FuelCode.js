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
        { name: 'strRinFuelCode', type: 'string', auditKey: true},
        { name: 'strDescription', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strRinFuelCode'}
    ]
});
