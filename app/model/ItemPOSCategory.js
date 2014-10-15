/**
 * Created by LZabala on 9/24/2014.
 */
Ext.define('Inventory.model.ItemPOSCategory', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemPOSCategoryId',

    fields: [
        { name: 'intItemPOSCategoryId', type: 'int'},
        { name: 'intItemId', type: 'int'},
        { name: 'intCategoryId', type: 'int'},
        { name: 'intSort', type: 'int'},

        { name: 'strCategory', type: 'string'}
    ]
});