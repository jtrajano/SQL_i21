Inventory.TestUtils.testModel({
    name: "Inventory.model.StorageType",
    base: "iRely.BaseEntity",
    idProperty: "intStorageTypeId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intStorageTypeId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strStorageType",
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
            "field": "strStorageType",
            "type": "presence"
        }]
    ]
});