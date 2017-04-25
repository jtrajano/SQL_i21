/**
 * Created by LZabala on 9/11/2014.
 */
Ext.define('Inventory.model.Item', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ItemUOM',
        'Inventory.model.ItemLocation',
        'Inventory.model.ItemVendorXref',
        'Inventory.model.ItemCustomerXref',
        'Inventory.model.ItemContract',
        'Inventory.model.ItemCertification',
        'Inventory.model.ItemPOSSLA',
        'Inventory.model.ItemPOSCategory',
        'Inventory.model.ItemManufacturingUOM',
        'Inventory.model.ItemAccount',
        'Inventory.model.ItemCommodityCost',
        'Inventory.model.ItemStock',
        'Inventory.model.ItemPricing',
        'Inventory.model.ItemPricingLevel',
        'Inventory.model.ItemSpecialPricing',
        'Inventory.model.ItemAssembly',
        'Inventory.model.ItemBundle',
        'Inventory.model.ItemKit',
        'Inventory.model.ItemNote',
        'Inventory.model.ItemOwner',
        'Inventory.model.ItemFactory',
        'Inventory.model.ItemMotorFuelTax',
        'Ext.data.Field'
    ],

    idProperty: 'intItemId',

    fields: [
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'strItemNo', type: 'string' },
        { name: 'strShortName', type: 'string' },
        { name: 'strType', type: 'string' },
        { name: 'strDescription', type: 'string' },
        { name: 'intManufacturerId', type: 'int', allowNull: true },
        { name: 'intBrandId', type: 'int', allowNull: true },
        { name: 'intCategoryId', type: 'int', allowNull: true },
        { name: 'strStatus', type: 'string' },
        { name: 'strModelNo', type: 'string' },
        { name: 'strInventoryTracking', type: 'string' },
        { name: 'strLotTracking', type: 'string' },
        { name: 'ysnRequireCustomerApproval', type: 'boolean' },
        { name: 'intRecipeId', type: 'int', allowNull: true },
        { name: 'ysnSanitationRequired', type: 'boolean' },
        { name: 'intLifeTime', type: 'int' },
        { name: 'strLifeTimeType', type: 'string' },
        { name: 'intReceiveLife', type: 'int' },
        { name: 'strGTIN', type: 'string' },
        { name: 'strRotationType', type: 'string' },
        { name: 'intNMFCId', type: 'int', allowNull: true },
        { name: 'ysnStrictFIFO', type: 'boolean' },
        { name: 'intDimensionUOMId', type: 'int', allowNull: true },
        { name: 'dblHeight', type: 'float' },
        { name: 'dblWidth', type: 'float' },
        { name: 'dblDepth', type: 'float' },
        { name: 'intWeightUOMId', type: 'int', allowNull: true },
        { name: 'dblWeight', type: 'float' },
        { name: 'intMaterialPackTypeId', type: 'int', allowNull: true },
        { name: 'strMaterialSizeCode', type: 'string' },
        { name: 'intInnerUnits', type: 'int' },
        { name: 'intLayerPerPallet', type: 'int' },
        { name: 'intUnitPerLayer', type: 'int' },
        { name: 'dblStandardPalletRatio', type: 'float' },
        { name: 'strMask1', type: 'string' },
        { name: 'strMask2', type: 'string' },
        { name: 'strMask3', type: 'string' },
        { name: 'dblMaxWeightPerPack', type: 'float' },
        { name: 'intPatronageCategoryId', type: 'int', allowNull: true },
        { name: 'intPatronageCategoryDirectId', type: 'int', allowNull: true },
        { name: 'intSalesTaxGroupId', type: 'int', allowNull: true },
        { name: 'intPurchaseTaxGroupId', type: 'int', allowNull: true },
        { name: 'ysnStockedItem', type: 'boolean' },
        { name: 'ysnDyedFuel', type: 'boolean' },
        { name: 'strBarcodePrint', type: 'string' },
        { name: 'ysnMSDSRequired', type: 'boolean' },
        { name: 'strEPANumber', type: 'string' },
        { name: 'ysnInboundTax', type: 'boolean' },
        { name: 'ysnOutboundTax', type: 'boolean' },
        { name: 'ysnRestrictedChemical', type: 'boolean' },
        { name: 'ysnFuelItem', type: 'boolean' },
        { name: 'ysnTankRequired', type: 'boolean' },
        { name: 'ysnAvailableTM', type: 'boolean' },
        { name: 'dblDefaultFull', type: 'float' },
        { name: 'strFuelInspectFee', type: 'string' },
        { name: 'strRINRequired', type: 'string' },
        { name: 'intRINFuelTypeId', type: 'int', allowNull: true },
        { name: 'dblDenaturantPercent', type: 'float' },
        { name: 'ysnTonnageTax', type: 'boolean' },
        { name: 'ysnLoadTracking', type: 'boolean' },
        { name: 'dblMixOrder', type: 'float' },
        { name: 'ysnHandAddIngredient', type: 'boolean' },
        { name: 'intMedicationTag', type: 'int', allowNull: true },
        { name: 'intIngredientTag', type: 'int', allowNull: true },
        { name: 'intHazmatMessage', type: 'int', allowNull: true },
        { name: 'intItemMessage', type: 'int', allowNull: true },
        { name: 'strVolumeRebateGroup', type: 'string' },
        { name: 'intPhysicalItem', type: 'int', allowNull: true },
        { name: 'ysnExtendPickTicket', type: 'boolean' },
        { name: 'ysnExportEDI', type: 'boolean' },
        { name: 'ysnHazardMaterial', type: 'boolean' },
        { name: 'ysnMaterialFee', type: 'boolean' },
        { name: 'ysnAutoBlend', type: 'boolean' },
        { name: 'dblUserGroupFee', type: 'float' },
        { name: 'dblWeightTolerance', type: 'float' },
        { name: 'dblOverReceiveTolerance', type: 'float' },
        { name: 'strMaintenanceCalculationMethod', type: 'string' },
        { name: 'dblMaintenanceRate', type: 'float' },
        { name: 'ysnListBundleSeparately', type: 'boolean' },
        { name: 'strNACSCategory', type: 'string' },
        { name: 'strWICCode', type: 'string' },
        { name: 'intAGCategory', type: 'int', allowNull: true },
        { name: 'ysnReceiptCommentRequired', type: 'boolean' },
        { name: 'strCountCode', type: 'string' },
        { name: 'ysnLandedCost', type: 'boolean' },
        { name: 'strLeadTime', type: 'string' },
        { name: 'ysnTaxable', type: 'boolean' },
        { name: 'strKeywords', type: 'string' },
        { name: 'dblCaseQty', type: 'float' },
        { name: 'dtmDateShip', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dblTaxExempt', type: 'float' },
        { name: 'ysnDropShip', type: 'boolean' },
        { name: 'ysnCommisionable', type: 'boolean' },
        { name: 'ysnSpecialCommission', type: 'boolean' },
        { name: 'intCommodityId', type: 'int', allowNull: true },
        { name: 'intCommodityHierarchyId', type: 'int', allowNull: true },
        { name: 'dblGAShrinkFactor', type: 'float' },
        { name: 'intOriginId', type: 'int', allowNull: true },
        { name: 'intProductTypeId', type: 'int', allowNull: true },
        { name: 'intRegionId', type: 'int', allowNull: true },
        { name: 'intSeasonId', type: 'int', allowNull: true },
        { name: 'intClassVarietyId', type: 'int', allowNull: true },
        { name: 'intProductLineId', type: 'int', allowNull: true },
        { name: 'intGradeId', type: 'int', allowNull: true },
        { name: 'strMarketValuation', type: 'string' },
        { name: 'ysnInventoryCost', type: 'boolean' },
        { name: 'ysnAccrue', type: 'boolean' },
        { name: 'ysnMTM', type: 'boolean' },
        { name: 'intM2MComputationId', type: 'int', allowNull: true },
        { name: 'strM2MComputation', type: 'string', allowNull: true },    
        { name: 'ysnPrice', type: 'boolean' },
        { name: 'strCostMethod', type: 'string' },
        { name: 'strCostType', type: 'string' },
        { name: 'intOnCostTypeId', type: 'int', allowNull: true },
        { name: 'dblAmount', type: 'float' },
        { name: 'intCostUOMId', type: 'int', allowNull: true },
        { name: 'intPackTypeId', type: 'int', allowNull: true },
        { name: 'strWeightControlCode', type: 'string' },
        { name: 'dblBlendWeight', type: 'float' },
        { name: 'dblNetWeight', type: 'float' },
        { name: 'dblUnitPerCase', type: 'float' },
        { name: 'dblQuarantineDuration', type: 'float' },
        { name: 'intOwnerId', type: 'int', allowNull: true },
        { name: 'intCustomerId', type: 'int', allowNull: true },
        { name: 'dblCaseWeight', type: 'float' },
        { name: 'strWarehouseStatus', type: 'string' },
        { name: 'ysnKosherCertified', type: 'boolean' },
        { name: 'ysnFairTradeCompliant', type: 'boolean' },
        { name: 'ysnOrganic', type: 'boolean' },
        { name: 'ysnRainForestCertified', type: 'boolean' },
        { name: 'dblRiskScore', type: 'float' },
        { name: 'dblDensity', type: 'float' },
        { name: 'dtmDateAvailable', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'ysnMinorIngredient', type: 'boolean' },
        { name: 'ysnExternalItem', type: 'boolean' },
        { name: 'strExternalGroup', type: 'string' },
        { name: 'ysnSellableItem', type: 'boolean' },
        { name: 'dblMinStockWeeks', type: 'float' },
        { name: 'dblFullContainerSize', type: 'float' },
        { name: 'ysnHasMFTImplication', type: 'boolean' },
        { name: 'ysnItemUsedInDiscountCode', type: 'boolean' },
        { name: 'strInvoiceComments', type: 'string' },
        { name: 'strPickListComments', type: 'string' },
        { name: 'intLotStatusId', type: 'int', allowNull: true },
        { name: 'strRequired', type: 'string' },
        { name: 'ysnBasisContract', type: 'boolean' },
        { name: 'intTonnageTaxUOMId', type: 'int', allowNull: true },
        { name: 'ysnUseWeighScales', type: 'boolean' }
    ],

    validators: [
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'strDescription'},
       // {type: 'presence', field: 'strStatus'},
       // {type: 'presence', field: 'intCategoryId'},
       // {type: 'presence', field: 'strInventoryTracking'},
       // {type: 'presence', field: 'strLotTracking'},

        { type: 'inclusion',
            field: 'strType',
            list: [
                'Inventory',
                'Non-Inventory',
                'Bundle',
                'Kit',
                'Finished Good',
                'Raw Material',
                'Other Charge',
                'Service',
                'Software',
                'Comment'
            ],
            message: 'Invalid Type! Please select an Item Type from the list.'
        }
    ],

    validate: function(options){
        var errors = this.callParent(arguments);
        if (this.get('strType') === 'Raw Material' || this.get('strType') === 'Finished Good') {
            if (this.get('intLifeTime') <= 0) {
                errors.add({
                    field: 'intLifeTime',
                    message: 'Lifetime must be greater than zero(0).'
                })
            }
            if (this.get('intReceiveLife') <= 0) {
                errors.add({
                    field: 'intReceiveLife',
                    message: 'Receive Life must be greater than zero(0).'
                })
            }
            if (iRely.Functions.isEmpty(this.get('strLifeTimeType'))) {
                errors.add({
                    field: 'strLifeTimeType',
                    message: 'Invalid Lifetime Type.'
                })
            }
        }
        
        if(this.get('strType') !== 'Comment' && (this.get('strStatus') === null || this.get('strStatus') === ''))
            {
               errors.add({
                    field: 'strStatus',
                    message: 'Status must be present' 
               })
            }
        
        if(this.get('strType') !== 'Comment' && (this.get('intCategoryId') === null || this.get('intCategoryId') === ''))
            {
               errors.add({
                    field: 'intCategoryId',
                    message: 'Category must be present' 
               })
            }
        
        if(this.get('strType') !== 'Comment' && (this.get('strInventoryTracking') === null || this.get('strInventoryTracking') === ''))
            {
               errors.add({
                    field: 'strInventoryTracking',
                    message: 'Inventory Tracking must be present' 
               })
            }
        
        if(this.get('strType') !== 'Comment' && (this.get('strLotTracking') === null || this.get('strLotTracking') === ''))
            {
               errors.add({
                    field: 'strLotTracking',
                    message: 'Lot Tracking must be present' 
               })
            }
        
        return errors;
    }
});