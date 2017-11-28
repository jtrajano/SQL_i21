UnitTestEngine.testModel({
    name: 'Inventory.model.ItemVendorXref',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemVendorXrefId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemVendorXrefId",
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
        "name": "intVendorId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strVendorProduct",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strProductDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblConversionFactor",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intItemUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strVendorId",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strVendorId",
            "type": "presence"
        }, {
            "field": "strVendorProduct",
            "type": "presence"
        }, {
            "field": "strProductDescription",
            "type": "presence"
        }]
    ]
});