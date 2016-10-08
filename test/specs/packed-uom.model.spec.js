Inventory.TestUtils.testModel({
    name: "Inventory.model.PackedUOM",
    base: "Ext.data.Model",
    idProperty: "undefined",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intUnitMeasureConversionId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strUnitType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strSymbol",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intStockUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strConversionUOM",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblConversionToStock",
        "type": "float",
        "allowNull": false
    }],
    validators: [
        []
    ]
});