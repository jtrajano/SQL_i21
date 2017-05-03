UnitTestEngine.testModel({
    name: 'Inventory.model.ItemOwner',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemOwnerId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemOwnerId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intOwnerId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnDefault",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strCustomerNumber",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strName",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strCustomerNumber",
            "type": "presence"
        }]
    ]
});