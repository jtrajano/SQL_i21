/**
 * Created by LZabala on 10/28/2014.
 */
Ext.define('Inventory.model.CompactItem', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemId',

    fields: [
        { name: 'intItemId', type: 'int' },
        { name: 'strItemNo', type: 'string' },
        { name: 'strType', type: 'string' },
        { name: 'strDescription', type: 'string' },
        { name: 'strManufacturer', type: 'string' },
        { name: 'strBrandCode', type: 'string' },
        { name: 'strBrandName', type: 'string' },
        { name: 'strStatus', type: 'string' },
        { name: 'strModelNo', type: 'string' },
        { name: 'strTracking', type: 'string' },
        { name: 'strLotTracking', type: 'string' },
        { name: 'intCommodityId', type: 'int', allowNull: true },
        { name: 'strCommodity', type: 'string' },
        { name: 'intCategoryId', type: 'int', allowNull: true },
        { name: 'strCategory', type: 'string' },
        { name: 'ysnInventoryCost', type: 'boolean' },
        { name: 'ysnAccrue', type: 'boolean' },
        { name: 'ysnMTM', type: 'boolean' },
        { name: 'ysnPrice', type: 'boolean' },
        { name: 'strCostMethod', type: 'string' },
        { name: 'intOnCostTypeId', type: 'int', allowNull: true },
        { name: 'strOnCostType', type: 'string' },
        { name: 'dblAmount', type: 'float' },
        { name: 'intCostUOMId', type: 'int', allowNull: true },
        { name: 'strCostUOM', type: 'string' }
    ]
});