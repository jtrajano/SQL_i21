Inventory.TestUtils.testModel({
    name: 'Inventory.model.CertificationCommodity',
    base: 'iRely.BaseEntity',
    idProperty: 'intCertificationCommodityId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCertificationCommodityId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCertificationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCommodityId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intCurrencyId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblCertificationPremium",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dtmDateEffective",
        "type": "date",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strCommodityCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strCurrency",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strCommodityCode",
            "type": "presence"
        }, {
            "field": "strCurrency",
            "type": "presence"
        }, {
            "field": "strUnitMeasure",
            "type": "presence"
        }, {
            "field": "dtmDateEffective",
            "type": "presence"
        }]
    ]
});