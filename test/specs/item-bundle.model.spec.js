UnitTestEngine.testModel({
    name: 'Inventory.model.ItemBundle',
    base: 'iRely.BaseEntity',
    idProperty: 'intItemBundleId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemBundleId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intBundleItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblQuantity",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intItemUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblMarkUpOrDown",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dtmBeginDate",
        "type": "date",
        "allowNull": false
    }, {
        "name": "dtmEndDate",
        "type": "date",
        "allowNull": false
    }, {
        "name": "strComponentItemNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strComponentItemNo",
            "type": "presence"
        }]
    ]
});