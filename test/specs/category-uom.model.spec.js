Inventory.TestUtils.testModel({
    name: 'Inventory.model.CategoryUOM',
    base: 'iRely.BaseEntity',
    idProperty: 'intCategoryUOMId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCategoryUOMId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCategoryId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblUnitQty",
        "type": "float",
        "allowNull": false
    }, {
        "name": "ysnStockUnit",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnAllowPurchase",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnAllowSale",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnDefault",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }],
    validators: [
        [{
            "field": "strUnitMeasure",
            "type": "presence"
        }]
    ]
});