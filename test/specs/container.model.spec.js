Inventory.TestUtils.testModel({
    name: "Inventory.model.Container",
    base: "iRely.BaseEntity",
    idProperty: "intContainerId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intContainerId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intExternalSystemId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strContainerId",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intContainerTypeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intStorageLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strLastUpdateBy",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dtmLastUpdateOn",
        "type": "date",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strContainerId",
            "type": "presence"
        }, {
            "field": "intContainerTypeId",
            "type": "presence"
        }]
    ]
});