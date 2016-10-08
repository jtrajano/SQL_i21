Inventory.TestUtils.testModel({
    name: "Inventory.model.ReceiptItemView",
    base: "iRely.BaseEntity",
    idProperty: "intInventoryReceiptItemId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intInventoryReceiptId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intInventoryReceiptItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "dblReceived",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblBillQty",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intSourceId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strOrderNumber",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strSourceNumber",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strSourceType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intRecordNo",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        []
    ]
});