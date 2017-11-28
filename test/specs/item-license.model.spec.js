UnitTestEngine.testModel({
    name: 'Inventory.model.ItemLicense',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemLicenseId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemLicenseId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intLicenseTypeId",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        []
    ]
});