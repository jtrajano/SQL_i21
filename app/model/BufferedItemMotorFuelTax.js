Ext.define('Inventory.model.BufferedItemMotorFuelTax', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemMotorFuelTaxId',

    fields: [
        { name: 'intItemMotorFuelTaxId', type: 'int'},
        { name: 'intItemId', type: 'int'},
        { name: 'intTaxAuthorityId', type: 'int', allowNull: true },
        { name: 'strTaxAuthorityCode', type: 'string'},
        { name: 'strTaxAuthorityDescription', type: 'string'},
        { name: 'intProductCodeId', type: 'int', allowNull: true },
        { name: 'strProductCode', type: 'string'},
        { name: 'strProductDescription', type: 'string'},
        { name: 'strProductCodeGroup', type: 'string'},       
        { name: 'strProductCode', type: 'string'}
    ]    
});