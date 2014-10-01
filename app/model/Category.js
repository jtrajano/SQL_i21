/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.model.Category', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.CategoryAccount',
        'Inventory.model.CategoryStore',
        'Inventory.model.CategoryVendor',
        'Ext.data.Field'
    ],

    idProperty: 'intCategoryId',

    fields: [
        { name: 'intCategoryId', type: 'int'},
        { name: 'strCategoryCode', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'strLineBusiness', type: 'string'},
        { name: 'intCatalogGroupId', type: 'int'},
        { name: 'strCostingMethod', type: 'string'},
        { name: 'strInventoryTracking', type: 'string'},
        { name: 'dblStandardQty', type: 'float'},
        { name: 'intUOMId', type: 'int'},
        { name: 'strGLDivisionNumber', type: 'string'},
        { name: 'ysnSalesAnalysisByTon', type: 'boolean'},
        { name: 'strMaterialFee', type: 'string'},
        { name: 'intMaterialItemId', type: 'int'},
        { name: 'ysnAutoCalculateFreight', type: 'boolean'},
        { name: 'intFreightItemId', type: 'int'},
        { name: 'ysnNonRetailUseDepartment', type: 'boolean'},
        { name: 'ysnReportNetGross', type: 'boolean'},
        { name: 'ysnDepartmentPumps', type: 'boolean'},
        { name: 'intConvertPaidOutId', type: 'int'},
        { name: 'ysnDeleteRegister', type: 'boolean'},
        { name: 'ysnDepartmentKeyTaxed', type: 'boolean'},
        { name: 'intProductCodeId', type: 'int'},
        { name: 'intFamilyId', type: 'int'},
        { name: 'intClassId', type: 'int'},
        { name: 'ysnFoodStampable', type: 'boolean'},
        { name: 'ysnReturnable', type: 'boolean'},
        { name: 'ysnSaleable', type: 'boolean'},
        { name: 'ysnPrepriced', type: 'boolean'},
        { name: 'ysnIdRequiredLiquor', type: 'boolean'},
        { name: 'ysnIdRequiredCigarette', type: 'boolean'},
        { name: 'intMinimumAge', type: 'int'},
        { name: 'strERPItemClass', type: 'string'},
        { name: 'dblfeTime', type: 'float'},
        { name: 'dblBOMItemShrinkage', type: 'float'},
        { name: 'dblBOMItemUpperTolerance', type: 'float'},
        { name: 'dblBOMItemLowerTolerance', type: 'float'},
        { name: 'ysnScaled', type: 'boolean'},
        { name: 'ysnOutputItemMandatory', type: 'boolean'},
        { name: 'strConsumptionMethod', type: 'string'},
        { name: 'strBOMItemType', type: 'string'},
        { name: 'strShortName', type: 'string'},
        { name: 'imgReceiptImage', type: 'byte[]'},
        { name: 'imgWIPImage', type: 'byte[]'},
        { name: 'imgFGImage', type: 'byte[]'},
        { name: 'imgShipImage', type: 'byte[]'},
        { name: 'dblLaborCost', type: 'float'},
        { name: 'dblOverHead', type: 'float'},
        { name: 'dblPercentage', type: 'float'},
        { name: 'strCostDistributionMethod', type: 'string'},
        { name: 'ysnSellable', type: 'boolean'},
        { name: 'ysnYieldAdjustment', type: 'boolean'},
    ],

    hasMany: [
        {
            model: 'Inventory.model.CategoryAccount',
            name: 'tblICCategoryAccounts',
            foreignKey: 'intCategoryId',
            primaryKey: 'intCategoryId',
            storeConfig: {
                sortOnLoad: true,
                sorters: {
                    direction: 'ASC',
                    property: 'intSort'
                }
            }
        },
        {
            model: 'Inventory.model.CategoryStore',
            name: 'tblICCategoryStores',
            foreignKey: 'intCategoryId',
            primaryKey: 'intCategoryId',
            storeConfig: {
                sortOnLoad: true,
                sorters: {
                    direction: 'ASC',
                    property: 'intSort'
                }
            }
        },
        {
            model: 'Inventory.model.CategoryVendor',
            name: 'tblICCategoryVendors',
            foreignKey: 'intCategoryId',
            primaryKey: 'intCategoryId',
            storeConfig: {
                sortOnLoad: true,
                sorters: {
                    direction: 'ASC',
                    property: 'intSort'
                }
            }
        }
    ]
});