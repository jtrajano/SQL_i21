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
        { name: 'intCommodityId', type: 'int'},
        { name: 'intUnitMeasureId', type: 'int'},
        { name: 'dblWeightPerPack', type: 'float'},
        { name: 'ysnStockUnit', type: 'boolean'},
        { name: 'ysnAllowPurchase', type: 'boolean'},
        { name: 'ysnAllowSale', type: 'boolean'},
        { name: 'intSort', type: 'int'}
    ]
});