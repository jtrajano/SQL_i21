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
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'strAccountDescription', type: 'string'},
        { name: 'intAccountId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'},
        { name: 'strAccountId', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strLocationName'},
        {type: 'presence', field: 'strAccountDescription'},
        {type: 'presence', field: 'strAccountId'}
    ]
});