Inventory.TestUtils.testModel({
    name: 'Inventory.model.FuelTaxClass',
    base: 'iRely.BaseEntity',
    idProperty: 'intFuelTaxClassId',
    dependencies: ["Inventory.model.FuelTaxClassProductCode", "Ext.data.Field"],
    fields: [{
        "name": "intFuelTaxClassId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strTaxClassCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strIRSTaxCode",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strTaxClassCode",
            "type": "presence"
        }]
    ]
});