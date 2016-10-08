Inventory.TestUtils.testModel({
    name: "Inventory.model.ItemCommodityCost",
    base: "iRely.BaseEntity",
    idProperty: "intItemCommodityCostId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemCommodityCostId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblLastCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblStandardCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblAverageCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblEOMCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strLocationName",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strLocationName",
            "type": "presence"
        }]
    ]
});