Inventory.TestUtils.testModel({
    name: 'Inventory.model.CompactItemFactory',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemFactoryId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemFactoryId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intFactoryId",
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