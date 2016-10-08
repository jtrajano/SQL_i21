Inventory.TestUtils.testModel({
    name: "Inventory.model.UnitMeasureConversion",
    base: "iRely.BaseEntity",
    idProperty: "intUnitMeasureConversionId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intUnitMeasureConversionId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intUnitMeasureId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intStockUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblConversionToStock",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strUnitMeasure",
            "type": "presence"
        }]
    ]
});