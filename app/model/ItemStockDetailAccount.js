/**
 * Created by LZabala on 1/5/2015.
 */
Ext.define('Inventory.model.ItemStockDetailAccount', {
    extend: 'Ext.data.Model',

    requires: [
        'Ext.data.Field'
    ],

    fields: [
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
        { name: 'strAccountDescription', type: 'string'},
        { name: 'intAccountId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int'},

        { name: 'strAccountId', type: 'string'},
        { name: 'strDescription', type: 'string'}
    ],

    validators: [
        { type: 'presence', field: 'strAccountDescription' },
        { type: 'presence', field: 'strAccountId' }
    ]
});