Inventory.TestUtils.testModel({
    name: 'Inventory.model.ItemManufacturingUOM',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemManufacturingUOMId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemManufacturingUOMId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
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