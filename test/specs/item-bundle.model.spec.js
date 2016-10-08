Inventory.TestUtils.testModel({
    name: "Inventory.model.ItemBundle",
    base: "iRely.BaseEntity",
    idProperty: "intItemBundleId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemBundleId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intBundleItemId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblQuantity",
        "type": "float",
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
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strItemNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strItemNo",
            "type": "presence"
        }, {
            "field": "strUnitMeasure",
            "type": "presence"
        }]
    ]
});