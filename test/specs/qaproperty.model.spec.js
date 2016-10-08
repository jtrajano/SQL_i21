Inventory.TestUtils.testModel({
    name: "Inventory.model.QAProperty",
    base: "iRely.BaseEntity",
    idProperty: "intQAPropertyId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intQAPropertyId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strPropertyName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strAnalysisType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDataType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strListName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intDecimalPlaces",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strMandatory",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnActive",
        "type": "boolean",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strPropertyName",
            "type": "presence"
        }]
    ]
});