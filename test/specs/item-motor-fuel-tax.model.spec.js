Inventory.TestUtils.testModel({
    name: 'Inventory.model.ItemMotorFuelTax',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemMotorFuelTaxId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemMotorFuelTaxId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intTaxAuthorityId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intProductCodeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strTaxAuthorityCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strProductCode",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strTaxAuthorityCode",
            "type": "presence"
        }, {
            "field": "strProductCode",
            "type": "presence"
        }]
    ]
});