Inventory.TestUtils.testModel({
    name: "Inventory.model.PackTypeDetail",
    base: "iRely.BaseEntity",
    idProperty: "intPackTypeDetailId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intPackTypeDetailId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intPackTypeId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intSourceUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intTargetUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblConversionFactor",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strSourceUnitMeasure",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strTargetUnitMeasure",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strSourceUnitMeasure",
            "type": "presence"
        }, {
            "field": "strTargetUnitMeasure",
            "type": "presence"
        }]
    ]
});