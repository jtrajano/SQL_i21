UnitTestEngine.testModel({
    name: 'Inventory.model.AdjustItemOwner',
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
        "allowNull": true
    }, {
        "name": "intOwnerId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnDefault",
        "type": "boolean",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strCustomerNumber",
        "type": "string",
        "allowNull": true
    }, {
        "name": "strName",
        "type": "string",
        "allowNull": true
    }],
    validators: [
        []
    ]
});