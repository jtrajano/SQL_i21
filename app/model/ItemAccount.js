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
        { name: 'strAccountDescription', type: 'string'},
        { name: 'intAccountId', type: 'int'},
        { name: 'intSort', type: 'int'},

        { name: 'strAccountId', type: 'string'},
        { name: 'strProfitCenter', type: 'string'}
    ],

    validators: [
        { type: 'presence', field: 'strAccountDescription' },
        { type: 'presence', field: 'intAccountId' }
    ]
});