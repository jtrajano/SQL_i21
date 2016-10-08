Inventory.TestUtils.testModel({
    name: 'Inventory.model.UnitMeasure',
    base: 'iRely.BaseEntity',
    idProperty: 'intUnitMeasureId',
    dependencies: ["Inventory.model.UnitMeasureConversion", "Ext.data.Field"],
    fields: [{
        "name": "intUnitMeasureId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strSymbol",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strUnitType",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strUnitMeasure",
            "type": "presence"
        }, {
            "field": "strUnitType",
            "type": "presence"
        }]
    ]
});