UnitTestEngine.testModel({
    name: 'Inventory.model.Document',
    base: 'iRely.BaseEntity',
    idProperty: 'intDocumentId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intDocumentId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strDocumentName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intDocumentType",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intCommodityId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnStandard",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intCertificationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intOriginal",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intCopies",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strCommodityCode",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strDocumentName",
            "type": "presence"
        }, {
            "field": "intCommodityId",
            "type": "presence"
        }, {
            "field": "intDocumentType",
            "type": "presence"
        }]
    ]
});