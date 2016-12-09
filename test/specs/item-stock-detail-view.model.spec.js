UnitTestEngine.testModel({
    name: 'Inventory.model.ItemStockDetailView',
    base: 'Ext.data.Model',
    idProperty: 'intKey',
    dependencies: ["Inventory.model.ItemStockDetailAccount", "Inventory.model.ItemStockDetailPricing", "Ext.data.Field"],
    fields: [{
        "name": "intKey",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strItemNo",
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
        "name": "strLotTracking",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strInventoryTracking",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strStatus",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intItemLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSubLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intCategoryId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strCategoryCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intCommodityId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strCommodityCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strStorageLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strSubLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intStorageLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strLocationType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intVendorId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strVendorId",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intStockUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strStockUOM",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strStockUOMType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intReceiveUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblReceiveUOMConvFactor",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intIssueUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblIssueUOMConvFactor",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strReceiveUOMType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strIssueUOMType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strReceiveUOM",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strReceiveUPC",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblReceiveSalePrice",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblReceiveMSRPPrice",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblReceiveLastCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblReceiveStandardCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblReceiveAverageCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblReceiveEndMonthCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strIssueUOM",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strIssueUPC",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblIssueSalePrice",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblIssueMSRPPrice",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblIssueLastCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblIssueStandardCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblIssueAverageCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblIssueEndMonthCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblMinOrder",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblReorderPoint",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intAllowNegativeInventory",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strAllowNegativeInventory",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intCostingMethod",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strCostingMethod",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblAmountPercent",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblSalePrice",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblMSRPPrice",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strPricingMethod",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblLastCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblStandardCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblAverageCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblEndMonthCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblUnitOnHand",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblOnOrder",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblOrderCommitted",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblBackOrder",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblDefaultFull",
        "type": "float",
        "allowNull": false
    }, {
        "name": "ysnAvailableTM",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "dblMaintenanceRate",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strMaintenanceCalculationMethod",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblOverReceiveTolerance",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblWeightTolerance",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intSalesTaxGroupId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strSalesTax",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intPurchaseTaxGroupId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strPurchaseTax",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        []
    ]
});