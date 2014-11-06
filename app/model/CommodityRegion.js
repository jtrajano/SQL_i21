/**
 * Created by LZabala on 11/6/2014.
 */
Ext.define('Inventory.model.CommodityRegion', {
    extend: 'iRely.BaseEntity',

    requires: [,
        'Ext.data.Field'
    ],

    idProperty: 'intCommodityAttributeId',

    fields: [
        { name: 'intCommodityAttributeId', type: 'int'},
        { name: 'intCommodityId', type: 'int',
            reference: {
                type: 'Inventory.model.Commodity',
                inverse: {
                    role: 'tblICCommodityRegions',
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
        { name: 'strDescription', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strDescription'}
    ]
});