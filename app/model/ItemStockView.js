/**
 * Created by LZabala on 11/25/2014.
 */
Ext.define('Inventory.model.ItemStockView', {
    extend: 'Ext.data.Model',

    requires: [
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
        { name: 'intDefaultUOMId', type: 'int'},
        { name: 'strDefaultUOM', type: 'string'},
        { name: 'intAllowNegativeInventory', type: 'int'},
        { name: 'strAllowNegativeInventory', type: 'string'},
        { name: 'intCostingMethod', type: 'int'},
        { name: 'strCostingMethod', type: 'string'},
        { name: 'intAccountId', type: 'int'},
        { name: 'strAccountId', type: 'string'},
        { name: 'strAccountDescription', type: 'string'},
        { name: 'intUnitMeasureId', type: 'int'},
        { name: 'strStockUOM', type: 'string'},
        { name: 'dblUnitOnHand', type: 'float'},
        { name: 'dblAverageCost', type: 'float'},
        { name: 'dblMinOrder', type: 'float'},
        { name: 'dblOnOrder', type: 'float'},
        { name: 'dblOrderCommitted', type: 'float'}
    ]
});