Inventory.TestUtils.testModel({
    name: 'Inventory.model.ProcessCode',
    base: 'iRely.BaseEntity',
    idProperty: 'intRinProcessId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intRinProcessId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strRinProcessCode",
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
            "field": "strRinProcessCode",
            "type": "presence"
        }]
    ]
});