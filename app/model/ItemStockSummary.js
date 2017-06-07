/**
 * Created by LZabala on 11/3/2015.
 */
Ext.define('Inventory.model.ItemStockSummary', {
    extend: 'Ext.data.Model',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intKey',

    fields: [
        { name: 'intKey', type: 'int' },
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'strItemNo', type: 'string' },
        { name: 'strItemDescription', type: 'string' },
        { name: 'strLotTracking', type: 'string' },
        { name: 'intCategoryId', type: 'int', allowNull: true },
        { name: 'strCategoryCode', type: 'string' },
        { name: 'intCommodityId', type: 'int', allowNull: true },
        { name: 'strCommodityCode', type: 'string' },
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'intCountGroupId', type: 'int', allowNull: true },
        { name: 'strLocationName', type: 'string' },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'strSubLocationName', type: 'string' },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'intLotId', type: 'int', allowNull: true },
        { name: 'strLotNumber', type: 'string' },
        { name: 'strLotAlias', type: 'string' },
        { name: 'dblStockIn', type: 'float' },
        { name: 'dblStockOut', type: 'float' },
        { name: 'dblOnHand', type: 'float' },
        { name: 'dblConversionFactor', type: 'float' },
        { name: 'dblLastCost', type: 'float' },
        { name: 'dblTotalCost', type: 'float' },
        { name: 'dblSystemCount', type: 'float' },
        { name: 'dblPhysicalCount', type: 'float' }
    ]
});