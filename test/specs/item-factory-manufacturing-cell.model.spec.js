Inventory.TestUtils.testModel({
    name: "Inventory.model.ItemFactoryManufacturingCell",
    base: "iRely.BaseEntity",
    idProperty: "intItemFactoryManufacturingCellId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemFactoryManufacturingCellId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemFactoryId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intManufacturingCellId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnDefault",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intPreference",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strCellName",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strCellName",
            "type": "presence"
        }]
    ]
});