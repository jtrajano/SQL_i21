Inventory.TestUtils.testModel({
    name: "Inventory.model.CommodityAccount",
    base: "iRely.BaseEntity",
    idProperty: "intCommodityAccountId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCommodityAccountId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCommodityId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intAccountCategoryId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intAccountId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strAccountCategory",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strAccountId",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strAccountCategory",
            "type": "presence"
        }, {
            "field": "strAccountId",
            "type": "presence"
        }]
    ]
});