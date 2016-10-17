Inventory.TestUtils.testModel({
    name: 'Inventory.model.ManufacturingCell',
    base: 'iRely.BaseEntity',
    idProperty: 'intManufacturingCellId',
    dependencies: ["Inventory.model.ManufacturingCellPackType", "Ext.data.Field"],
    fields: [{
        "name": "intManufacturingCellId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strCellName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnActive",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "dblStdCapacity",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intStdUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intStdCapacityRateId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblStdLineEfficiency",
        "type": "float",
        "allowNull": false
    }, {
        "name": "ysnIncludeSchedule",
        "type": "boolean",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strCellName",
            "type": "presence"
        }]
    ]
});