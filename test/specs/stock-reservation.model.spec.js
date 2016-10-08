Inventory.TestUtils.testModel({
    name: "Inventory.model.StockReservation",
    base: "iRely.BaseEntity",
    idProperty: "intStockReservationId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intStockReservationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intItemLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intItemUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblQuantity",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intTransactionId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strTransactionId",
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