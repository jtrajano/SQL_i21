UnitTestEngine.testModel({
    name: 'Inventory.model.ItemSubLocationsLookup',
    base: 'iRely.BaseEntity',
    idProperty: 'intSubLocationId',
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
        "name": "intItemLocationId",
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
        "name": "strClassification",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        []
    ]
});