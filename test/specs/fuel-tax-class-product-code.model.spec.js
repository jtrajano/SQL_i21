Inventory.TestUtils.testModel({
    name: 'Inventory.model.FuelTaxClassProductCode',
    base: 'iRely.BaseEntity',
    idProperty: 'intFuelTaxClassProductCodeId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intFuelTaxClassProductCodeId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intFuelTaxClassId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strState",
        "type": "string",
        "allowNull": true
    }, {
        "name": "strProductCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strState",
            "type": "presence"
        }]
    ]
});