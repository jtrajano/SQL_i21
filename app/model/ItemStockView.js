/**
 * Created by LZabala on 11/25/2014.
 */
Ext.define('Inventory.model.ItemStockView', {
    extend: 'Ext.data.Model',

    requires: [
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
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'strSubLocationName', type: 'string' },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'strLocationName', type: 'string' },
        { name: 'strLocationType', type: 'string' },
        { name: 'intVendorId', type: 'int', allowNull: true },
        { name: 'strVendorId', type: 'string' },
        { name: 'intStockUOMId', type: 'int', allowNull: true },
        { name: 'strStockUOM', type: 'string' },
        { name: 'strStockUOMType', type: 'string' },
        { name: 'intReceiveUOMId', type: 'int', allowNull: true },
        { name: 'dblReceiveUOMConvFactor', type: 'float' },
        { name: 'intIssueUOMId', type: 'int', allowNull: true },
        { name: 'dblIssueUOMConvFactor', type: 'float' },
        { name: 'strReceiveUOMType', type: 'string' },
        { name: 'strIssueUOMType', type: 'string' },
        { name: 'strReceiveUOM', type: 'string' },
        { name: 'dblReceiveSalePrice', type: 'float' },
        { name: 'dblReceiveMSRPPrice', type: 'float' },
        { name: 'dblReceiveLastCost', type: 'float' },
        { name: 'dblReceiveStandardCost', type: 'float' },
        { name: 'dblReceiveAverageCost', type: 'float' },
        { name: 'dblReceiveEndMonthCost', type: 'float' },
        { name: 'strIssueUOM', type: 'string' },
        { name: 'dblIssueSalePrice', type: 'float' },
        { name: 'dblIssueMSRPPrice', type: 'float' },
        { name: 'dblIssueLastCost', type: 'float' },
        { name: 'dblIssueStandardCost', type: 'float' },
        { name: 'dblIssueAverageCost', type: 'float' },
        { name: 'dblIssueEndMonthCost', type: 'float' },
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