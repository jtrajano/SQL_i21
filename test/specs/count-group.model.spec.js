Inventory.TestUtils.testModel({
    name: 'Inventory.model.CountGroup',
    base: 'iRely.BaseEntity',
    idProperty: 'intCountGroupId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCountGroupId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strCountGroup",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intCountsPerYear",
        "type": "int",
        "allowNull": false
    }, {
        "name": "ysnIncludeOnHand",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnScannedCountEntry",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnCountByLots",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnCountByPallets",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnRecountMismatch",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnExternal",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }],
    validators: [
        [{
            "field": "strCountGroup",
            "type": "presence"
        }]
    ]
});