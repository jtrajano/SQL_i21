UnitTestEngine.testModel({
    name: 'Inventory.model.ImportLogDetail',
    base: 'iRely.BaseEntity',
    idProperty: 'intImportLogIdDetail',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intImportLogIdDetail",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intImportLogId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intRecordNo",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strField",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strValue",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strMessage",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strStatus",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strAction",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "intImportLogIdDetail",
            "type": "presence"
        }, {
            "field": "intImportLogId",
            "type": "presence"
        }]
    ]
});