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
        { name: 'intKey', type: 'int'},
        { name: 'intItemId', type: 'int'},
        { name: 'strItemNo', type: 'string'},
        { name: 'strType', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intLocationId', type: 'int'},
        { name: 'strLocationName', type: 'string'},
        { name: 'strLocationType', type: 'string'},
        { name: 'intVendorId', type: 'int'},
        { name: 'strVendorId', type: 'string'},
        { name: 'intReceiveUOMId', type: 'int'},
        { name: 'intIssueUOMId', type: 'int'},
        { name: 'strReceiveUOM', type: 'string'},
        { name: 'strIssueUOM', type: 'string'},
        { name: 'intAllowNegativeInventory', type: 'int'},
        { name: 'strAllowNegativeInventory', type: 'string'},
        { name: 'intCostingMethod', type: 'int'},
        { name: 'strCostingMethod', type: 'string'},
        { name: 'intUnitMeasureId', type: 'int'},
        { name: 'strStockUOM', type: 'string'},
        { name: 'dblUnitOnHand', type: 'float'},
        { name: 'dblAverageCost', type: 'float'},
        { name: 'dblOnOrder', type: 'float'},
        { name: 'dblOrderCommitted', type: 'float'},
    ]
});