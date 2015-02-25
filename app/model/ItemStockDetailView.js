/**
 * Created by LZabala on 1/5/2015.
 */
Ext.define('Inventory.model.ItemStockDetailView', {
    extend: 'Ext.data.Model',

    requires: [
        'Inventory.model.ItemStockDetailAccount',
        'Inventory.model.ItemStockDetailPricing',
        'Ext.data.Field'
    ],

    fields: [
        { name: 'intKey', type: 'int', allowNull: true },
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'strItemNo', type: 'string' },
        { name: 'strType', type: 'string' },
        { name: 'strDescription', type: 'string' },
        { name: 'strLotTracking', type: 'string' },
        { name: 'strInventoryTracking', type: 'string' },
        { name: 'strStatus', type: 'string' },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'strLocationName', type: 'string' },
        { name: 'strLocationType', type: 'string' },
        { name: 'intVendorId', type: 'int', allowNull: true },
        { name: 'strVendorId', type: 'string' },
        { name: 'intReceiveUOMId', type: 'int', allowNull: true },
        { name: 'intIssueUOMId', type: 'int', allowNull: true },
        { name: 'strReceiveUOM', type: 'string' },
        { name: 'strIssueUOM', type: 'string' },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'dblMinOrder', type: 'float' },
        { name: 'dblReorderPoint', type: 'float' },
        { name: 'intAllowNegativeInventory', type: 'int', allowNull: true },
        { name: 'strAllowNegativeInventory', type: 'string' },
        { name: 'intCostingMethod', type: 'int', allowNull: true },
        { name: 'strCostingMethod', type: 'string' },
        { name: 'dblAmountPercent', type: 'float' },
        { name: 'dblSalePrice', type: 'float' },
        { name: 'dblMSRPPrice', type: 'float' },
        { name: 'strPricingMethod', type: 'string' },
        { name: 'dblLastCost', type: 'float' },
        { name: 'dblStandardCost', type: 'float' },
        { name: 'dblAverageCost', type: 'float' },
        { name: 'dblEndMonthCost', type: 'float' },
        { name: 'dblUnitOnHand', type: 'float' },
        { name: 'dblOnOrder', type: 'float' },
        { name: 'dblOrderCommitted', type: 'float' },
        { name: 'dblBackOrder', type: 'float' }
    ]
});