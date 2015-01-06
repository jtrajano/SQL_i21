/**
 * Created by LZabala on 10/9/2014.
 */
Ext.define('Inventory.model.PricingLevel', {
    extend: 'Ext.data.Model',

    requires: [
        'Ext.data.Field'
    ],

    fields: [
        { name: 'intKey', type: 'int'},
        { name: 'intCompanyLocationId', type: 'int'},
        { name: 'strPricingLevel', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strPricingLevel'}
    ]
});