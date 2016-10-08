Inventory.TestUtils.testModel({
    name: "Inventory.model.ParentLot",
    base: "iRely.BaseEntity",
    idProperty: "intParentLotId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intParentLotId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strParentLotNumber",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strParentLotAlias",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strParentLotNumber",
            "type": "presence"
        }]
    ]
});