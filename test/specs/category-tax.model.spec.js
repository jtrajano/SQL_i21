Inventory.TestUtils.testModel({
    name: "Inventory.model.CategoryTax",
    base: "iRely.BaseEntity",
    idProperty: "intCategoryTaxId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCategoryTaxId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCategoryId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intTaxClassId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strTaxClass",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strTaxClass",
            "type": "presence"
        }]
    ]
});