UnitTestEngine.testModel({
    name: 'Inventory.model.ItemSubstitute',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemSubstituteId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemSubstituteId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intSubstituteItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "dblQuantity",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblMarkUpOrDown",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dtmBeginDate",
        "type": "date",
        "allowNull": false
    }, {
        "name": "dtmEndDate",
        "type": "date",
        "allowNull": false
    }, {
        "name": "intItemUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strSubstituteItemNo",
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
            "field": "strSubstituteItemNo",
            "type": "presence"
        }, {
            "field": "strUnitMeasure",
            "type": "presence"
        }]
    ]
});