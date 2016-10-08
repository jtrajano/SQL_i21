Inventory.TestUtils.testModel({
    name: 'Inventory.model.Lot',
    base: 'iRely.BaseEntity',
    idProperty: 'intLotId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intLotId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strLotNumber",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strLotId",
            "type": "presence"
        }]
    ]
});