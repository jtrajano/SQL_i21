Inventory.TestUtils.testModel({
    name: "Inventory.model.ItemNote",
    base: "iRely.BaseEntity",
    idProperty: "intItemNoteId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intItemNoteId",
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
        "name": "strCommentType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strComments",
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
    }],
    validators: [
        [{
            "field": "strLocationName",
            "type": "presence"
        }]
    ]
});