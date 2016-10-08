Inventory.TestUtils.testModel({
    name: "Inventory.model.BuildAssembly",
    base: "iRely.BaseEntity",
    idProperty: "intBuildAssemblyId",
    dependencies: ["Inventory.model.BuildAssemblyDetail", "Ext.data.Field"],
    fields: [{
        "name": "intBuildAssemblyId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dtmBuildDate",
        "type": "date",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strBuildNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblBuildQuantity",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intSubLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intItemUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnPosted",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intCreatedUserId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intEntityId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }],
    validators: [
        [{
            "field": "dtmBuildDate",
            "type": "presence"
        }, {
            "field": "intItemId",
            "type": "presence"
        }, {
            "field": "intLocationId",
            "type": "presence"
        }, {
            "field": "intItemUOMId",
            "type": "presence"
        }]
    ]
});