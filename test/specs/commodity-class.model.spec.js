UnitTestEngine.testModel({
    name: 'Inventory.model.CommodityClass',
    base: 'iRely.BaseEntity',
    idProperty: 'intCommodityAttributeId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCommodityAttributeId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCommodityId",
        "type": "int",
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