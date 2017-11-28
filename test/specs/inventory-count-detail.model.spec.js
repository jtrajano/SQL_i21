UnitTestEngine.testModel({
    name: 'Inventory.model.InventoryCountDetail',
    base: 'iRely.BaseEntity',
    idProperty: 'intInventoryCountDetailId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intInventoryCountDetailId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intInventoryCountId",
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
        "name": "intSubLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intStorageLocationId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intCountGroupId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intLotId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblSystemCount",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblLastCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strCountLine",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblPallets",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblQtyPerPallet",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblPhysicalCount",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intItemUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strStockUOM",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intStockUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnRecount",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intEntityUserSecurityId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strItemNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strItemDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strLotTracking",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strCategory",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strSubLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strStorageLocationName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strLotNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strLotAlias",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strParentLotAlias",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strParentLotNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intParentLotId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strWeightUOM",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intWeightUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblWeightQty",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblNetQty",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblConversionFactor",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblItemUOMConversionFactor",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblWeightUOMConversionFactor",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblQtyReceived",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblQtySold",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblPhysicalCountStockUnit",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblVariance",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strUserName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnLotted",
        "type": "boolean",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "intItemId",
            "type": "presence"
        }, {
            "field": "intItemUOMId",
            "type": "presence"
        }]
    ]
});