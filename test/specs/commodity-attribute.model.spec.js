Inventory.TestUtils.testModel({
    name: 'Inventory.model.CommodityAttribute',
    base: 'iRely.BaseEntity',
    idProperty: 'intCommodityAttributeId',
    dependencies: ["Inventory.model.Commodity", "Ext.data.Field"],
    fields: [{
        "name": "intCommodityAttributeId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCommodityId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strType",
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
            "field": "strDescription",
            "type": "presence"
        }]
    ]
});