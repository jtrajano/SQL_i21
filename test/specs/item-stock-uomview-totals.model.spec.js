UnitTestEngine.testModel({
    name: 'Inventory.model.ItemStockUOMViewTotals',
    base: 'Ext.data.Model',
    idProperty: 'intItemStockUOMId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemStockUOMId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intItemUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSubLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strSubLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strStorageLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblAvailableQty",
        "type": "float",
        "allowNull": true
    }, {
        "name": "dblStorageQty",
        "type": "float",
        "allowNull": true
    }],
    validators: [
        []
    ]
});