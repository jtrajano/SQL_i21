UnitTestEngine.testModel({
    name: 'Inventory.model.ItemAddOn',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemAddOnId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemAddOnId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intAddOnItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "dblQuantity",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intItemUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strAddOnItemNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strAddOnItemNo",
            "type": "presence"
        }, {
            "field": "strUnitMeasure",
            "type": "presence"
        }]
    ]
});