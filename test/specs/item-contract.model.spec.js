UnitTestEngine.testModel({
    name: 'Inventory.model.ItemContract',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemContractId',
    dependencies: ["Inventory.model.ItemContractDocument", "Ext.data.Field"],
    fields: [{
        "name": "intItemContractId",
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
        "name": "strContractItemName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intCountryId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strGrade",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strGradeType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strGarden",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblYieldPercent",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblTolerancePercent",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblFranchisePercent",
        "type": "float",
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
        "name": "strCountry",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strContractItemNo",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strLocationName",
            "type": "presence"
        }, {
            "field": "strContractItemName",
            "type": "presence"
        }]
    ]
});