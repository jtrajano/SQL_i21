Inventory.TestUtils.testModel({
    name: "Inventory.model.ItemKitDetail",
    base: "iRely.BaseEntity",
    idProperty: "intItemKitDetailId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemKitDetailId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemKitId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblQuantity",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intItemUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblPrice",
        "type": "float",
        "allowNull": false
    }, {
        "name": "ysnSelected",
        "type": "int",
        "allowNull": true
    }, {
        "name": "inSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strItemNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
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