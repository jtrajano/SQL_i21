/**
 * Created by LZabala on 10/21/2014.
 */
Ext.define('Inventory.model.FuelTaxClass', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.FuelTaxClassProductCode',
        'Ext.data.Field'
    ],

    idProperty: 'intFuelTaxClassId',

    fields: [
        { name: 'intFuelTaxClassId', type: 'int'},
        { name: 'strTaxClassCode', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'strIRSTaxCode', type: 'string'}
    ],

    validators: [
        { type: 'presence', field: 'strTaxClassCode' }
    ]
});