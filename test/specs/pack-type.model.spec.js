Inventory.TestUtils.testModel({
    name: "Inventory.model.PackType",
    base: "iRely.BaseEntity",
    idProperty: "intPackTypeId",
    dependencies: ["Inventory.model.PackTypeDetail", "Ext.data.Field"],
    fields: [{
        "name": "intPackTypeId",
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