Inventory.TestUtils.testModel({
    name: 'Inventory.model.CompactCommodity',
    base: 'iRely.BaseEntity',
    idProperty: 'intCommodityId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCommodityId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strCommodityCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strCommodityCode",
            "type": "presence"
        }]
    ]
});