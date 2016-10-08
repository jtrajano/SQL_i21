Inventory.TestUtils.testModel({
    name: 'Inventory.model.ItemStockDetailAccount',
    base: 'Ext.data.Model',
    idProperty: 'intAccountKey',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intAccountKey",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intKey",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemAccountId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intAccountId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strAccountId",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intAccountGroupId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strAccountGroup",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strAccountType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intAccountCategoryId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strAccountCategory",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }],
    validators: [
        []
    ]
});