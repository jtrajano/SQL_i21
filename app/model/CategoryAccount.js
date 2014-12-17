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
        { name: 'strAccountDescription', type: 'string'},
        { name: 'intAccountId', type: 'int', allowNull: true },

        { name: 'strAccountId', type: 'int', allowNull: true }
    ],

    validators: [
        {type: 'presence', field: 'strAccountId'},
        {type: 'presence', field: 'strAccountDescription'}
    ]
});