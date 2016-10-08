Inventory.TestUtils.testModel({
    name: "Inventory.model.ItemPOSCategory",
    base: "iRely.BaseEntity",
    idProperty: "intItemPOSCategoryId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemPOSCategoryId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCategoryId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strCategory",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strCategory",
            "type": "presence"
        }]
    ]
});