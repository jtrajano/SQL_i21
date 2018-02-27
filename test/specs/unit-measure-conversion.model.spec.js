UnitTestEngine.testModel({
    name: 'Inventory.model.UnitMeasureConversion',
    base: 'iRely.BaseEntity',
    idProperty: 'intUnitMeasureConversionId',
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
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strStockUOM",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strStockUOM",
            "type": "presence"
        }, {
            "field": "dblConversionToStock",
            "type": "presence"
        }]
    ]
});