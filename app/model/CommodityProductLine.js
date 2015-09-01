/**
 * Created by LZabala on 11/6/2014.
 */
Ext.define('Inventory.model.CommodityProductLine', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCommodityProductLineId',

    fields: [
        { name: 'intCommodityProductLineId', type: 'int'},
        { name: 'intCommodityId', type: 'int',
            reference: {
                type: 'Inventory.model.Commodity',
                inverse: {
                    role: 'tblICCommodityProductLines',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'strDescription', type: 'string'},
        { name: 'ysnDeltaHedge', type: 'boolean'},
        { name: 'dblDeltaPercent', type: 'float'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strDescription'}
    ]
});