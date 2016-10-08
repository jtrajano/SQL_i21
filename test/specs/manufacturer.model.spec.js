Inventory.TestUtils.testModel({
    name: "Inventory.model.Manufacturer",
    base: "iRely.BaseEntity",
    idProperty: "intManufacturerId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intManufacturerId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strManufacturer",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strContact",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strAddress",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strZipCode ",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strCity",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strState",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strCountry",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strPhone",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strFax",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strWebsite",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strEmail",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strNotes",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strManufacturer",
            "type": "presence"
        }]
    ]
});