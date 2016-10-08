Inventory.TestUtils.testModel({
    name: "Inventory.model.TransferNote",
    base: "iRely.BaseEntity",
    idProperty: "intInventoryTransferNoteId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intInventoryTransferNoteId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intInventoryTransferId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strNoteType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strNotes",
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