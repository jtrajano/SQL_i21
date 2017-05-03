UnitTestEngine.testModel({
    name: 'Inventory.model.Certification',
    base: 'iRely.BaseEntity',
    idProperty: 'intCertificationId',
    dependencies: ["Inventory.model.CertificationCommodity", "Ext.data.Field"],
    fields: [{
        "name": "intCertificationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strCertificationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strIssuingOrganization",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnGlobalCertification",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intCountryId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strCertificationIdName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strCertificationCode",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strCertificationName",
            "type": "presence"
        }, {
            "field": "strIssuingOrganization",
            "type": "presence"
        }]
    ]
});