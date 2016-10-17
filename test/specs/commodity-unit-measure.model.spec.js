Inventory.TestUtils.testModel({
    name: 'Inventory.model.CommodityUnitMeasure',
    base: 'iRely.BaseEntity',
    idProperty: 'intCommodityUnitMeasureId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCommodityUnitMeasureId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCommodityId",
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
        "name": "ysnDefault",
        "type": "boolean",
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