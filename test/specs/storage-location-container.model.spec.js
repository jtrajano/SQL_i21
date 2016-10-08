Inventory.TestUtils.testModel({
    name: 'Inventory.model.StorageLocationContainer',
    base: 'iRely.BaseEntity',
    idProperty: 'intStorageLocationContainerId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intStorageLocationContainerId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intStorageLocationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intContainerId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intExternalSystemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intContainerTypeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strLastUpdatedBy",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dtmLastUpdatedOn",
        "type": "date",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strContainer",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strContainerType",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strContainer",
            "type": "presence"
        }]
    ]
});