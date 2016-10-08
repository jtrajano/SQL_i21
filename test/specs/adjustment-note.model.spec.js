Inventory.TestUtils.testModel({
    name: "Inventory.model.AdjustmentNote",
    base: "iRely.BaseEntity",
    idProperty: "intInventoryAdjustmentNoteId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intInventoryAdjustmentNoteId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intInventoryAdjustmentId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strDescription",
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