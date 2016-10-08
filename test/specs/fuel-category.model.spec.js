Inventory.TestUtils.testModel({
    name: "Inventory.model.FuelCategory",
    base: "iRely.BaseEntity",
    idProperty: "intRinFuelCategoryId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intRinFuelCategoryId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strRinFuelCategoryCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strEquivalenceValue",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strRinFuelCategoryCode",
            "type": "presence"
        }]
    ]
});