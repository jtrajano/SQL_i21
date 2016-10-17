Inventory.TestUtils.testModel({
    name: 'Inventory.model.ItemCertification',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemCertificationId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemCertificationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCertificationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strCertificationName",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strCertificationName",
            "type": "presence"
        }]
    ]
});