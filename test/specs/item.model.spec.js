UnitTestEngine.testModel({
    name: 'Inventory.model.Item',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemId',
    dependencies: ["Inventory.model.ItemUOM", "Inventory.model.ItemLocation", "Inventory.model.ItemVendorXref", "Inventory.model.ItemCustomerXref", "Inventory.model.ItemContract", "Inventory.model.ItemCertification", "Inventory.model.ItemPOSSLA", "Inventory.model.ItemPOSCategory", "Inventory.model.ItemManufacturingUOM", "Inventory.model.ItemAccount", "Inventory.model.ItemCommodityCost", "Inventory.model.ItemStock", "Inventory.model.ItemPricing", "Inventory.model.ItemPricingLevel", "Inventory.model.ItemSpecialPricing", "Inventory.model.ItemAssembly", "Inventory.model.ItemBundle", "Inventory.model.ItemKit", "Inventory.model.ItemNote", "Inventory.model.ItemOwner", "Inventory.model.ItemFactory", "Inventory.model.ItemMotorFuelTax", "Inventory.model.ItemLicense", "Ext.data.Field"],
    fields: [{
        "name": "intItemId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strItemNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strShortName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intManufacturerId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intBrandId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intCategoryId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strStatus",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strModelNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strInventoryTracking",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strLotTracking",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnRequireCustomerApproval",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intRecipeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnSanitationRequired",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intLifeTime",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strLifeTimeType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intReceiveLife",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strGTIN",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strRotationType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intNMFCId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnStrictFIFO",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intDimensionUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblHeight",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblWidth",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblDepth",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intWeightUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblWeight",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intMaterialPackTypeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strMaterialSizeCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intInnerUnits",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intLayerPerPallet",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intUnitPerLayer",
        "type": "int",
        "allowNull": false
    }, {
        "name": "dblStandardPalletRatio",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strMask1",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strMask2",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strMask3",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblMaxWeightPerPack",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intPatronageCategoryId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intPatronageCategoryDirectId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSalesTaxGroupId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intPurchaseTaxGroupId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnStockedItem",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnDyedFuel",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strBarcodePrint",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnMSDSRequired",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strEPANumber",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnInboundTax",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnOutboundTax",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnRestrictedChemical",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnFuelItem",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnTankRequired",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnAvailableTM",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "dblDefaultFull",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strFuelInspectFee",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strRINRequired",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intRINFuelTypeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblDenaturantPercent",
        "type": "float",
        "allowNull": false
    }, {
        "name": "ysnTonnageTax",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnLoadTracking",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "dblMixOrder",
        "type": "float",
        "allowNull": false
    }, {
        "name": "ysnHandAddIngredient",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intMedicationTag",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intIngredientTag",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intHazmatMessage",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strVolumeRebateGroup",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intPhysicalItem",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnExtendPickTicket",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnExportEDI",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnHazardMaterial",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnMaterialFee",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnAutoBlend",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "dblUserGroupFee",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblWeightTolerance",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblOverReceiveTolerance",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strMaintenanceCalculationMethod",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblMaintenanceRate",
        "type": "float",
        "allowNull": false
    }, {
        "name": "ysnListBundleSeparately",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strNACSCategory",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strWICCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intAGCategory",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnReceiptCommentRequired",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strCountCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnLandedCost",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strLeadTime",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnTaxable",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strKeywords",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblCaseQty",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dtmDateShip",
        "type": "date",
        "allowNull": false
    }, {
        "name": "dblTaxExempt",
        "type": "float",
        "allowNull": false
    }, {
        "name": "ysnDropShip",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnCommisionable",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnSpecialCommission",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intCommodityId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intCommodityHierarchyId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblGAShrinkFactor",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intOriginId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intProductTypeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intRegionId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSeasonId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intClassVarietyId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intProductLineId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intGradeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strMarketValuation",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnInventoryCost",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnAccrue",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnMTM",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intM2MComputationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strM2MComputation",
        "type": "string",
        "allowNull": true
    }, {
        "name": "ysnPrice",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strCostMethod",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strCostType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intOnCostTypeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblAmount",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intCostUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intPackTypeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strWeightControlCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblBlendWeight",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblNetWeight",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblUnitPerCase",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblQuarantineDuration",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intOwnerId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intCustomerId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblCaseWeight",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strWarehouseStatus",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnKosherCertified",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnFairTradeCompliant",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnOrganic",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnRainForestCertified",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "dblRiskScore",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblDensity",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dtmDateAvailable",
        "type": "date",
        "allowNull": false
    }, {
        "name": "ysnMinorIngredient",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnExternalItem",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strExternalGroup",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnSellableItem",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "dblMinStockWeeks",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblFullContainerSize",
        "type": "float",
        "allowNull": false
    }, {
        "name": "ysnHasMFTImplication",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnItemUsedInDiscountCode",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strInvoiceComments",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strPickListComments",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intLotStatusId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strRequired",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnBasisContract",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intTonnageTaxUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnUseWeighScales",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnIsBasket",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnLotWeightsRequired",
        "type": "boolean",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strItemNo",
            "type": "presence"
        }, {
            "field": "strType",
            "type": "inclusion"
        }]
    ]
});