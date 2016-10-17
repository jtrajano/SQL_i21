Inventory.TestUtils.testModel({
    name: 'Inventory.model.Status',
    base: 'iRely.BaseEntity',
    idProperty: 'intStatusId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intStatusId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strStatus",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strStatus",
            "type": "presence"
        }]
    ]
});