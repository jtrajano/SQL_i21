Inventory.TestUtils.testModel({
    name: 'Inventory.model.StorageLocationCategory',
    base: 'iRely.BaseEntity',
    idProperty: 'intStorageLocationCategoryId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intStorageLocationCategoryId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intStorageLocationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCategoryId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strCategoryCode",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strCategoryCode",
            "type": "presence"
        }]
    ]
});