Inventory.TestUtils.testModel({
    name: 'Inventory.model.ItemPOSSLA',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemPOSSLAId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemPOSSLAId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strSLAContract",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblContractPrice",
        "type": "float",
        "allowNull": false
    }, {
        "name": "ysnServiceWarranty",
        "type": "boolean",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strSLAContract",
            "type": "presence"
        }]
    ]
});