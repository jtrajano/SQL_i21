Inventory.TestUtils.testModel({
    name: 'Inventory.model.StorageLocationMeasurement',
    base: 'iRely.BaseEntity',
    idProperty: 'intStorageLocationMeasurementId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intStorageLocationMeasurementId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intStorageLocationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intMeasurementId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intReadingPointId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnActive",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strMeasurementName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strReadingPoint",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strMeasurementName",
            "type": "presence"
        }, {
            "field": "strReadingPoint",
            "type": "presence"
        }]
    ]
});