UnitTestEngine.testModel({
    name: 'Inventory.model.ItemAccountView',
    base: 'Ext.data.Model',
    idProperty: 'intItemAccountId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemId",
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
        "name": "strAccountId",
        "type": "string",
        "allowNull": true
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": true
    }, {
        "name": "strAccountGroup",
        "type": "string",
        "allowNull": true
    }, {
        "name": "strAccountCategory",
        "type": "string",
        "allowNull": true
    }, {
        "name": "strAccountType",
        "type": "string",
        "allowNull": true
    }],
    validators: [
        []
    ]
});