/**
 * Created by rnkumashi on 16-09-2014.
 */

Ext.define('Inventory.model.PatronageCategory', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intPatronageCategoryId',

    fields: [
        { name: 'intPatronageCategoryId', type: 'int'},
        { name: 'strCategoryCode', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'strPurchaseSale', type: 'string'},
        { name: 'strUnitAmount', type: 'string'},
        { name: 'intSort', type: 'int'}

    ],
    validators: [
        {type: 'presence', field: 'strCategoryCode'}
    ]
});