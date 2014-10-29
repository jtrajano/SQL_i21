/**
 * Created by LZabala on 10/3/2014.
 */
Ext.define('Inventory.model.CommodityUnitMeasure', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCommodityUnitMeasureId',

    fields: [
        { name: 'intCommodityUnitMeasureId', type: 'int'},
        { name: 'intCommodityId', type: 'int',
            reference: {
                type: 'Inventory.model.Commodity',
                inverse: {
                    role: 'tblICCommodityUnitMeasures',
                    storeConfig: {
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }},
        { name: 'intUnitMeasureId', type: 'int'},
        { name: 'dblWeightPerPack', type: 'float'},
        { name: 'ysnStockUnit', type: 'boolean'},
        { name: 'ysnAllowPurchase', type: 'boolean'},
        { name: 'ysnAllowSale', type: 'boolean'},
        { name: 'intSort', type: 'int'}
    ]
});