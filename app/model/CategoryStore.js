/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.model.CategoryStore', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCategoryStoreId',

    fields: [
        { name: 'intCategoryStoreId', type: 'int'},
        { name: 'intCategoryId', type: 'int'},
        { name: 'intStoreId', type: 'int'},
        { name: 'intRegisterDepartmentId', type: 'int'},
        { name: 'ysnUpdatePrices', type: 'boolean'},
        { name: 'ysnUseTaxFlag1', type: 'boolean'},
        { name: 'ysnUseTaxFlag2', type: 'boolean'},
        { name: 'ysnUseTaxFlag3', type: 'boolean'},
        { name: 'ysnUseTaxFlag4', type: 'boolean'},
        { name: 'ysnBlueLaw1', type: 'boolean'},
        { name: 'ysnBlueLaw2', type: 'boolean'},
        { name: 'intNucleusGroupId', type: 'int'},
        { name: 'dblTargetGrossProfit', type: 'float'},
        { name: 'dblTargetInventoryCost', type: 'float'},
        { name: 'dblCostInventoryBOM', type: 'float'},
        { name: 'dblLowGrossMarginAlert', type: 'float'},
        { name: 'dblHighGrossMarginAlert', type: 'float'},
        { name: 'dtmLastInventoryLevelEntry', type: 'date'},
    ]
});