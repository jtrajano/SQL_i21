Inventory.TestUtils.testModel({
    name: 'Inventory.model.ItemUPC',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemUPCId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemUPCId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblUnitQty",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strUPCCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strUnitMeasure",
            "type": "presence"
        }]
    ]
});