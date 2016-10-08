Inventory.TestUtils.testModel({
    name: "Inventory.model.StorageMeasurementReading",
    base: "iRely.BaseEntity",
    idProperty: "intStorageMeasurementReadingId",
    dependencies: ["Inventory.model.StorageMeasurementReadingConversion", "Ext.data.Field"],
    fields: [{
        "name": "intStorageMeasurementReadingId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dtmDate",
        "type": "date",
        "allowNull": false
    }, {
        "name": "strReadingNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }],
    validators: [
        [{
            "field": "intLocationId",
            "type": "presence"
        }]
    ]
});