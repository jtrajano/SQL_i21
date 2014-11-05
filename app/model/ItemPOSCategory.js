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
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemPOSCategories',
                    storeConfig: {
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intCategoryId', type: 'int'},
        { name: 'intSort', type: 'int'},

        { name: 'strCategory', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intCategoryId'}
    ]
});