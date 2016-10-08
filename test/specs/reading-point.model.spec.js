Inventory.TestUtils.testModel({
    name: "Inventory.model.ReadingPoint",
    base: "iRely.BaseEntity",
    idProperty: "intReadingPointId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intReadingPointId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strReadingPoint",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strReadingPoint",
            "type": "presence"
        }]
    ]
});