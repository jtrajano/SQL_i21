UnitTestEngine.testModel({
    name: 'Inventory.model.BufferedItemMotorFuelTax',
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
        "name": "strTaxAuthorityCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strTaxAuthorityDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intProductCodeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strProductCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strProductDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strProductCodeGroup",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strProductCode",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        []
    ]
});