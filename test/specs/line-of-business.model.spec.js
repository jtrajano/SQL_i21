Inventory.TestUtils.testModel({
    name: 'Inventory.model.LineOfBusiness',
    base: 'iRely.BaseEntity',
    idProperty: 'intLineOfBusinessId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intLineOfBusinessId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strLineOfBusiness",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strLineOfBusiness",
            "type": "presence"
        }]
    ]
});