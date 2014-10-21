/**
 * Created by LZabala on 10/21/2014.
 */
Ext.define('Inventory.model.FuelTaxClassProductCode', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intFuelTaxClassProductCodeId',

    fields: [
        { name: 'intFuelTaxClassProductCodeId', type: 'int'},
        { name: 'intFuelTaxClassId', type: 'int'},
        { name: 'strState', type: 'string'},
        { name: 'strProductCode', type: 'string'},
        { name: 'intSort', type: 'int'}
    ]
});