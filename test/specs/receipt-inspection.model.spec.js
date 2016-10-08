Inventory.TestUtils.testModel({
    name: "Inventory.model.ReceiptInspection",
    base: "iRely.BaseEntity",
    idProperty: "intInventoryReceiptInspectionId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intInventoryReceiptInspectionId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intInventoryReceiptId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intQAPropertyId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnSelected",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strPropertyName",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "intQAPropertyId",
            "type": "presence"
        }]
    ]
});