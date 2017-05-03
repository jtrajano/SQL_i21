UnitTestEngine.testModel({
    name: 'Inventory.model.ItemSubLocation',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemSubLocationId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemSubLocationId",
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
    }],
    validators: [
        []
    ]
});