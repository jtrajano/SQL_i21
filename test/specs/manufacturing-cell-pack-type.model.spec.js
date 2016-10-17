Inventory.TestUtils.testModel({
    name: 'Inventory.model.ManufacturingCellPackType',
    base: 'iRely.BaseEntity',
    idProperty: 'intManufacturingCellPackTypeId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intManufacturingCellPackTypeId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intManufacturingCellId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intPackTypeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblLineCapacity",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intLineCapacityUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intLineCapacityRateUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblLineEfficiencyRate",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strPackName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strPackName",
            "type": "presence"
        }]
    ]
});