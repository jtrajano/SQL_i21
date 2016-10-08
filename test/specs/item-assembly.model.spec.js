Inventory.TestUtils.testModel({
    name: "Inventory.model.ItemAssembly",
    base: "iRely.BaseEntity",
    idProperty: "intItemAssemblyId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemAssemblyId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intAssemblyItemId",
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
        "name": "dblCost",
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