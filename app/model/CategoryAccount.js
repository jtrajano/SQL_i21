/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.model.CategoryAccount', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCategoryAccountId',

    fields: [
        { name: 'intCategoryAccountId', type: 'int'},
        { name: 'intCategoryId', type: 'int'},
        { name: 'intLocationId', type: 'int'},
        { name: 'intStoreId', type: 'int'},
        { name: 'strAccountDescription', type: 'string'},
        { name: 'intAccountId', type: 'int'},
    ]
});