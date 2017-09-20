UnitTestEngine.testModel({
    name: 'Inventory.model.CommodityGradeView',
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
        "name": "strGrade",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strCommodityCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strCommodityDescription",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        []
    ]
});