/**
 * Created by LZabala on 10/28/2014.
 */
Ext.define('Inventory.model.CommodityAttribute', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.Commodity',
        'Ext.data.Field'
    ],

    idProperty: 'intCommodityAttributeId',

    fields: [
        { name: 'intCommodityAttributeId', type: 'int'},
        { name: 'intCommodityId', type: 'int',
            reference: {
                type: 'Inventory.model.Commodity',
                inverse: {
                    role: 'tblICCommodityAttributes',
                    storeConfig: {
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'strType', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intSort', type: 'int'}
    ]
});