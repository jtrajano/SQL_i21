Inventory.TestUtils.testModel({
    name: "Inventory.model.ItemCustomerXref",
    base: "iRely.BaseEntity",
    idProperty: "intItemCustomerXrefId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemCustomerXrefId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intCustomerId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strCustomerProduct",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strProductDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strPickTicketNotes",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strCustomerNumber",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strLocationName",
            "type": "presence"
        }, {
            "field": "strCustomerNumber",
            "type": "presence"
        }, {
            "field": "strCustomerProduct",
            "type": "presence"
        }, {
            "field": "strProductDescription",
            "type": "presence"
        }]
    ]
});