Inventory.TestUtils.testModel({
    name: "Inventory.model.CategoryAccount",
    base: "iRely.BaseEntity",
    idProperty: "intCategoryAccountId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCategoryAccountId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCategoryId",
        "type": "int",
        "allowNull": false
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
        "name": "strAccountId",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strAccountCategory",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strAccountId",
            "type": "presence"
        }, {
            "field": "strAccountCategory",
            "type": "presence"
        }]
    ]
});