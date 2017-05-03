UnitTestEngine.testModel({
    name: 'Inventory.model.CommodityOrigin',
    base: 'iRely.BaseEntity',
    idProperty: 'intCommodityAttributeId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intCommodityAttributeId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intCommodityId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intDefaultPackingUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strDefaultPackingUOM",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intPurchasingGroupId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strPurchasingGroup",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intCountryID",
        "type": "int",
        "allowNull": true
    }],
    validators: [
        [{
            "field": "strDescription",
            "type": "presence"
        }]
    ]
});