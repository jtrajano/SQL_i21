Inventory.TestUtils.testModel({
    name: 'Inventory.model.Measurement',
    base: 'iRely.BaseEntity',
    idProperty: 'intMeasurementId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intMeasurementId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strMeasurementName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strMeasurementType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strMeasurementName",
            "type": "presence"
        }, {
            "field": "strMeasurementType",
            "type": "presence"
        }]
    ]
});