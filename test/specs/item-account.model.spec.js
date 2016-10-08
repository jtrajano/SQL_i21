Inventory.TestUtils.testModel({
    name: 'Inventory.model.ItemAccount',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemAccountId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemAccountId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
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
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strAccountCategory",
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