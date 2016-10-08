Inventory.TestUtils.testModel({
    name: "Inventory.model.FuelCode",
    base: "iRely.BaseEntity",
    idProperty: "intRinFuelId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intRinFuelId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strRinFuelCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strRinFuelCode",
            "type": "presence"
        }]
    ]
});