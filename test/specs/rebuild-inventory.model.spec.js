UnitTestEngine.testModel({
    name: 'Inventory.model.RebuildInventory',
    base: 'iRely.BaseEntity',
    idProperty: 'intId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "dtmDate",
        "type": "date",
        "allowNull": false
    }, {
        "name": "strPostOrder",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intMonth",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strMonth",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strItemNo",
        "type": "string",
        "allowNull": true
    }],
    validators: [
        [{
            "field": "dtmDate",
            "type": "presence"
        }, {
            "field": "strPostOrder",
            "type": "presence"
        }, {
            "field": "intMonth",
            "type": "presence"
        }]
    ]
});