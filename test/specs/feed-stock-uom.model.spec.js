Inventory.TestUtils.testModel({
    name: 'Inventory.model.FeedStockUom',
    base: 'iRely.BaseEntity',
    idProperty: 'intRinFeedStockUOMId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intRinFeedStockUOMId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strRinFeedStockUOMCode",
        "type": "string",
        "allowNull": false
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