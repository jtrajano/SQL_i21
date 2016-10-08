Inventory.TestUtils.testModel({
    name: "Inventory.model.ItemContractDocument",
    base: "iRely.BaseEntity",
    idProperty: "intItemContractDocumentId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemContractDocumentId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemContractId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intDocumentId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strDocumentName",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strDocumentName",
            "type": "presence"
        }]
    ]
});