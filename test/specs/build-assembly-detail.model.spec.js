Inventory.TestUtils.testModel({
    name: "Inventory.model.BuildAssemblyDetail",
    base: "iRely.BaseEntity",
    idProperty: "intInventoryAdjustmentDetailId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intBuildAssemblyDetailId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intBuildAssemblyId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSubLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblQuantity",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intItemUOMId",
        "type": "int",
        "allowNull": true
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
    }, {
        "name": "strSubLocationName",
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