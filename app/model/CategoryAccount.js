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
        { name: 'intCategoryId', type: 'int',
            reference: {
                type: 'Inventory.model.Category',
                inverse: {
                    role: 'tblICCategoryAccounts',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }},
        { name: 'intAccountCategoryId', type: 'int', allowNull: true },
        { name: 'intAccountId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strAccountId', type: 'string' },
        { name: 'strAccountCategory', type: 'string' }
    ],

    validators: [
        {type: 'presence', field: 'strAccountId'},
        {type: 'presence', field: 'strAccountCategory'}
    ]
});