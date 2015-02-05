/**
 * Created by LZabala on 10/20/2014.
 */
Ext.define('Inventory.model.ItemAccount', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemAccountId',

    fields: [
        { name: 'intItemAccountId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemAccounts',
                    storeConfig: {
                        complete: false,
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemAccount/GetItemAccounts'
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
        { name: 'intAccountCategoryId', type: 'int', allowNull: true },
        { name: 'intAccountId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strAccountId', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'strAccountCategory', type: 'string'}
    ],

    validators: [
        { type: 'presence', field: 'strAccountCategory' },
        { type: 'presence', field: 'strAccountId' }
    ]
});