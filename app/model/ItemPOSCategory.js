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
                        remoteFilter: true,
                        proxy: {
                            extraParams: { include: 'tblICCategory' },
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemPOSCategory/Get'
                            },
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            }
                        },
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intCategoryId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int'},

        { name: 'strCategory', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strCategory'}
    ]
});