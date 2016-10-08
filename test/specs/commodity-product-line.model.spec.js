Inventory.TestUtils.testModel({
    name: "Inventory.model.CommodityProductLine",
    base: "iRely.BaseEntity",
    idProperty: "intCommodityProductLineId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCommodityProductLineId",
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
        "name": "ysnDeltaHedge",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "dblDeltaPercent",
        "type": "float",
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