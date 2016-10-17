Inventory.TestUtils.testModel({
    name: 'Inventory.model.MaterialNMFC',
    base: 'iRely.BaseEntity',
    idProperty: 'intMaterialNMFCId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intMaterialNMFCId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intExternalSystemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strInternalCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strDisplayMember",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnDefault",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnLocked",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strLastUpdateBy",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dtmLastUpdateOn",
        "type": "date",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        []
    ]
});