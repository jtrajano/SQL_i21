UnitTestEngine.testModel({
    name: 'Inventory.model.ImportLog',
    base: 'iRely.BaseEntity',
    idProperty: 'intImportLogId',
    dependencies: ["Ext.data.Field", "Inventory.model.ImportLogDetail"],
    fields: [{
        "name": "intImportLogId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intTotalRows",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intRowsImported",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intTotalErrors",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intTotalWarnings",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblTimeSpentInSeconds",
        "type": "float",
        "allowNull": true
    }, {
        "name": "intUserEntityId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strFileType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strFileName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dtmDateImported",
        "type": "date",
        "allowNull": true
    }, {
        "name": "ysnAllowDuplicates",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnAllowOverwriteOnImport",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strLineOfBusiness",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnContinueOnFailedImports",
        "type": "boolean",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "intImportLogId",
            "type": "presence"
        }]
    ]
});