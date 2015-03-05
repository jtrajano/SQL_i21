/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.model.Category', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.CategoryAccount',
        'Inventory.model.CategoryLocation',
        'Inventory.model.CategoryVendor',
        'Inventory.model.CategoryUOM',
        'Ext.data.Field'
    ],

    idProperty: 'intCategoryId',

    fields: [
        { name: 'intCategoryId', type: 'int' },
        { name: 'strCategoryCode', type: 'string' },
        { name: 'strDescription', type: 'string' },
        { name: 'intLineOfBusinessId', type: 'int', allowNull: true },
        { name: 'intCatalogGroupId', type: 'int', allowNull: true },
        { name: 'intCostingMethod', type: 'int', allowNull: true },
        { name: 'strInventoryTracking', type: 'string' },
        { name: 'dblStandardQty', type: 'float' },
        { name: 'intUOMId', type: 'int', allowNull: true },
        { name: 'strGLDivisionNumber', type: 'string' },
        { name: 'ysnSalesAnalysisByTon', type: 'boolean' },
        { name: 'strMaterialFee', type: 'string' },
        { name: 'intMaterialItemId', type: 'int', allowNull: true },
        { name: 'ysnAutoCalculateFreight', type: 'boolean' },
        { name: 'intFreightItemId', type: 'int', allowNull: true },
        { name: 'strERPItemClass', type: 'string' },
        { name: 'dblLifeTime', type: 'float' },
        { name: 'dblBOMItemShrinkage', type: 'float' },
        { name: 'dblBOMItemUpperTolerance', type: 'float' },
        { name: 'dblBOMItemLowerTolerance', type: 'float' },
        { name: 'ysnScaled', type: 'boolean' },
        { name: 'ysnOutputItemMandatory', type: 'boolean' },
        { name: 'strConsumptionMethod', type: 'string' },
        { name: 'strBOMItemType', type: 'string' },
        { name: 'strShortName', type: 'string' },
        { name: 'imgReceiptImage', type: 'string' },
        { name: 'imgWIPImage', type: 'string' },
        { name: 'imgFGImage', type: 'string' },
        { name: 'imgShipImage', type: 'string' },
        { name: 'dblLaborCost', type: 'float' },
        { name: 'dblOverHead', type: 'float' },
        { name: 'dblPercentage', type: 'float' },
        { name: 'strCostDistributionMethod', type: 'string' },
        { name: 'ysnSellable', type: 'boolean' },
        { name: 'ysnYieldAdjustment', type: 'boolean' }
    ],

    validators: [
        {type: 'presence', field: 'strCategoryCode'},
        {type: 'presence', field: 'intCostingMethod'}
    ]
});