UnitTestEngine.testModel({
    name: 'Inventory.model.InventoryTag',
    base: 'iRely.BaseEntity',
    idProperty: 'intTagId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intTagId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strTagNumber",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strMessage",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnHazMat",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intType",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strType",
            "type": "presence"
        }, {
            "field": "strTagNumber",
            "type": "presence"
        }]
    ]
});