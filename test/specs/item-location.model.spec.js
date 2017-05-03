UnitTestEngine.testModel({
    name: 'Inventory.model.ItemLocation',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemLocationId',
    dependencies: ["Ext.data.Field", "Inventory.model.ItemSubLocation"],
    fields: [{
        "name": "intItemLocationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intVendorId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intCostingMethod",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intAllowNegativeInventory",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSubLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intStorageLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intIssueUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intReceiveUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intFamilyId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intClassId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intProductCodeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intFuelTankId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strPassportFuelId1",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strPassportFuelId2",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strPassportFuelId3",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnTaxFlag1",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnTaxFlag2",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnTaxFlag3",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnTaxFlag4",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnPromotionalItem",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intMixMatchId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnDepositRequired",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intDepositPLUId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intBottleDepositNo",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnSaleable",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnQuantityRequired",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnScaleItem",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnFoodStampable",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnReturnable",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnPrePriced",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnOpenPricePLU",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnLinkedItem",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strVendorCategory",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnCountBySINo",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strSerialNoBegin",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strSerialNoEnd",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnIdRequiredLiquor",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnIdRequiredCigarette",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intMinimumAge",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnApplyBlueLaw1",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnApplyBlueLaw2",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnCarWash",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intItemTypeCode",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intItemTypeSubCode",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnAutoCalculateFreight",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intFreightMethodId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblFreightRate",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intShipViaId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intNegativeInventory",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblReorderPoint",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblMinOrder",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblSuggestedQty",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblLeadTime",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strCounted",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intCountGroupId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnCountedDaily",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strVendorId",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strCategory",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "intLocationId",
            "type": "presence"
        }]
    ]
});