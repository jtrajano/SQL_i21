Inventory.TestUtils.testModel({
    name: "Inventory.model.StorageLocationSku",
    base: "iRely.BaseEntity",
    idProperty: "intStorageLocationSkuId",
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intStorageLocationSkuId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intStorageLocationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSkuId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblQuantity",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intContainerId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intLotCodeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intLotStatusId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intOwnerId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strSKU",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strItemNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strContainer",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strLotStatus",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "intItemId",
            "type": "presence"
        }, {
            "field": "intSkuId",
            "type": "presence"
        }]
    ]
});