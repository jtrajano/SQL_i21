Inventory.TestUtils.testModel({
    name: "Inventory.model.FeedStockCode",
    base: "iRely.BaseEntity",
    idProperty: "intRinFeedStockId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intRinFeedStockId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strRinFeedStockCode",
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
            "field": "strRinFeedStockCode",
            "type": "presence"
        }]
    ]
});