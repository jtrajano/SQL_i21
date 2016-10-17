Inventory.TestUtils.testModel({
    name: 'Inventory.model.LotStatus',
    base: 'iRely.BaseEntity',
    idProperty: 'intLotStatusId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intLotStatusId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strSecondaryStatus",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strPrimaryStatus",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strBackColor",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strSecondaryStatus",
            "type": "presence"
        }]
    ]
});