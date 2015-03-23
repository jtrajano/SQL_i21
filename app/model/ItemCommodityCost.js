/**
 * Created by LZabala on 10/9/2014.
 */
Ext.define('Inventory.model.ItemCommodityCost', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemCommodityCostId',

    fields: [
        { name: 'intItemCommodityCostId', type: 'int' },
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemCommodityCosts',
                    storeConfig: {
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemCommodityCost/GetItemCommodityCosts'
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
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'dblLastCost', type: 'float' },
        { name: 'dblStandardCost', type: 'float' },
        { name: 'dblAverageCost', type: 'float' },
        { name: 'dblEOMCost', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strLocationName', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strLocationName'}
    ]
});