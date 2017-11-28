UnitTestEngine.testModel({
    name: 'Inventory.model.ItemStorageLocationsLookup',
    base: 'iRely.BaseEntity',
    idProperty: 'intStorageLocationId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strItemNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intLocationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intSubLocationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strSubLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intStorageLocationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strStorageLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strStorageLocationDescription",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        []
    ]
});