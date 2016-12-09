UnitTestEngine.testModel({
    name: 'Inventory.model.ItemPricingLevel',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemPricingLevelId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemPricingLevelId",
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
        "name": "strPriceLevel",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intItemUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblUnit",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblMin",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblMax",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strPricingMethod",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblAmountRate",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblUnitPrice",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strCommissionOn",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblCommissionRate",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strUPC",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strLocationName",
            "type": "presence"
        }, {
            "field": "strPriceLevel",
            "type": "presence"
        }, {
            "field": "strUnitMeasure",
            "type": "presence"
        }, {
            "field": "dblUnit",
            "type": "presence"
        }, {
            "field": "strPricingMethod",
            "type": "presence"
        }, {
            "field": "dblUnitPrice",
            "type": "presence"
        }]
    ]
});