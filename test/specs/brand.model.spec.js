Inventory.TestUtils.testModel({
    name: "Inventory.model.Brand",
    base: "iRely.BaseEntity",
    idProperty: "intBrandId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intBrandId",
        "type": "int",
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
        "name": "intManufacturerId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strManufacturer",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strBrandCode",
            "type": "presence"
        }]
    ]
});