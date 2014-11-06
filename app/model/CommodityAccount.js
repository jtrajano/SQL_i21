/**
 * Created by LZabala on 10/31/2014.
 */
Ext.define('Inventory.model.CommodityAccount', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCommodityAccountId',

    fields: [
        { name: 'intCommodityAccountId', type: 'int'},
        { name: 'intCommodityId', type: 'int',
            reference: {
                type: 'Inventory.model.Commodity',
                inverse: {
                    role: 'tblICCommodityAccounts',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }},
        { name: 'intLocationId', type: 'int'},
        { name: 'strAccountDescription', type: 'string'},
        { name: 'intAccountId', type: 'int'},
        { name: 'intSort', type: 'int'},
    ],

    validators: [
        {type: 'presence', field: 'intLocationId'},
        {type: 'presence', field: 'intAccountId'}
    ]
});