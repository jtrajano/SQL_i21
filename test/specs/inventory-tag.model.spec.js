Inventory.TestUtils.testModel({
    name: "Inventory.model.InventoryTag",
    base: "iRely.BaseEntity",
    idProperty: "intTagId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intTagId",
        "type": "int",
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
    }],
    validators: [
        [{
            "field": "strTagNumber",
            "type": "presence"
        }]
    ]
});