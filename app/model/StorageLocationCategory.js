/**
 * Created by LZabala on 11/19/2014.
 */
Ext.define('Inventory.model.StorageLocationCategory', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intStorageLocationCategoryId',

    fields: [
        { name: 'intStorageLocationCategoryId', type: 'int'},
        { name: 'intStorageLocationId', type: 'int',
            reference: {
                type: 'Inventory.model.StorageLocation',
                inverse: {
                    role: 'tblICStorageLocationCategories',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intCategoryId', type: 'int', allowNull: true},
        { name: 'intSort', type: 'int'},

        { name: 'strCategoryCode', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intCategoryId'}
    ]
});