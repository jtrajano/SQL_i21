Inventory.TestUtils.testModel({
    name: "Inventory.model.CategoryLocation",
    base: "iRely.BaseEntity",
    idProperty: "intCategoryStoreId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCategoryLocationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCategoryId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intLocationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intRegisterDepartmentId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnUpdatePrices",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnUseTaxFlag1",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnUseTaxFlag2",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnUseTaxFlag3",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnUseTaxFlag4",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnBlueLaw1",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnBlueLaw2",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intNucleusGroupId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblTargetGrossProfit",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblTargetInventoryCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblCostInventoryBOM",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblLowGrossMarginAlert",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblHighGrossMarginAlert",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dtmLastInventoryLevelEntry",
        "type": "date",
        "allowNull": false
    }, {
        "name": "ysnNonRetailUseDepartment",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnReportNetGross",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnDepartmentForPumps",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intConvertPaidOutId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnDeleteFromRegister",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnDeptKeyTaxed",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intProductCodeId",
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
        "name": "ysnFoodStampable",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnReturnable",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnSaleable",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnPrePriced",
        "type": "boolean",
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
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }],
    validators: [
        [{
            "field": "intLocationId",
            "type": "presence"
        }]
    ]
});