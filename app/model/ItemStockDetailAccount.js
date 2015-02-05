/**
 * Created by LZabala on 1/5/2015.
 */
Ext.define('Inventory.model.ItemStockDetailAccount', {
    extend: 'Ext.data.Model',

    requires: [
        'Ext.data.Field'
    ],

    fields: [
        { name: 'intAccountKey', type: 'int'},
        { name: 'intKey', type: 'int'},
        { name: 'intItemAccountId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.ItemStockDetailView',
                inverse: {
                    role: 'tblICItemAccounts',
                    storeConfig: {
                        complete: true,
                        remoteFilter: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intAccountId', type: 'int', allowNull: true },
        { name: 'strAccountId', type: 'string' },
        { name: 'intAccountGroupId', type: 'int', allowNull: true },
        { name: 'strAccountGroup', type: 'string' },
        { name: 'strAccountType', type: 'string' },
        { name: 'intAccountCategoryId', type: 'int', allowNull: true },
        { name: 'strAccountCategory', type: 'string' },
        { name: 'intSort', type: 'int', allowNull: true },
    ]
});