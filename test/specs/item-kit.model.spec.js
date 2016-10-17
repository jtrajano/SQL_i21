Inventory.TestUtils.testModel({
    name: 'Inventory.model.ItemKit',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemKitId',
    dependencies: ["Inventory.model.ItemKitDetail", "Ext.data.Field"],
    fields: [{
        "name": "intItemKitId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strComponent",
        "type": "string",
        "allowNull": true
    }, {
        "name": "strInputType",
        "type": "string",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strComponent",
            "type": "presence"
        }, {
            "field": "strInputType",
            "type": "presence"
        }]
    ]
});