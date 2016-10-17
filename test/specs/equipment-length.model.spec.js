Inventory.TestUtils.testModel({
    name: 'Inventory.model.EquipmentLength',
    base: 'iRely.BaseEntity',
    idProperty: 'intEquipmentLengthId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intEquipmentLengthId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strEquipmentLength",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "intEquipmentLengthId",
            "type": "presence"
        }]
    ]
});