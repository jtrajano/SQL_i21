Inventory.TestUtils.testModel({
    name: 'Inventory.model.CategoryVendor',
    base: 'iRely.BaseEntity',
    idProperty: 'intCategoryVendorId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCategoryVendorId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCategoryId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCategoryLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intVendorId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strVendorDepartment",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnAddOrderingUPC",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnUpdateExistingRecords",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnAddNewRecords",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnUpdatePrice",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intFamilyId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSellClassId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intOrderClassId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strComments",
        "type": "string",
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
        "name": "strFamilyId",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strSellClassId",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strOrderClassId",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strLocationName",
            "type": "presence"
        }, {
            "field": "strVendorId",
            "type": "presence"
        }]
    ]
});