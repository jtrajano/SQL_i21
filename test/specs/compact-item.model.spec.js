UnitTestEngine.testModel({
    name: 'Inventory.model.CompactItem',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemId",
        "type": "int",
        "allowNull": false
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
        "name": "strManufacturer",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strBrandCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strBrandName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strStatus",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strModelNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strTracking",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strLotTracking",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intCommodityId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strCommodity",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intCategoryId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strCategory",
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
        "allowNull": false
    }, {
        "name": "ysnPrice",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strCostMethod",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intOnCostTypeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strOnCostType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblAmount",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intCostUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strCostUOM",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strCostType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strShortName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnBasisContract",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnUseWeighScales",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnIsBasket",
        "type": "boolean",
        "allowNull": false
    }],
    validators: [
        []
    ]
});