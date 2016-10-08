Inventory.TestUtils.testModel({
    name: 'Inventory.model.Restriction',
    base: 'iRely.BaseEntity',
    idProperty: 'intRestrictionId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intRestrictionId",
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
        [{
            "field": "strInternalCode",
            "type": "presence"
        }]
    ]
});