UnitTestEngine.testModel({
    name: 'Inventory.model.CompanyPreference',
    base: 'iRely.BaseEntity',
    idProperty: 'intCompanyPreferenceId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCompanyPreferenceId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intInheritSetup",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strLotCondition",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strReceiptType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intReceiptSourceType",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intShipmentOrderType",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intShipmentSourceType",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strOriginLastTask",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strOriginLineOfBusiness",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        []
    ]
});