UnitTestEngine.testModel({
    name: 'Inventory.model.ReceiptItem',
    base: 'iRely.BaseEntity',
    idProperty: 'intInventoryReceiptItemId',
    dependencies: ["Inventory.model.ReceiptItemLot", "Inventory.model.ReceiptItemTax", "Ext.data.Field"],
    fields: [{
        "name": "intInventoryReceiptItemId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intInventoryReceiptId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intLineNo",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intOrderId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intSourceId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intItemId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intContainerId",
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
        "name": "intOwnershipType",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblOrderQty",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblBillQty",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblOpenReceive",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblReceived",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intItemUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intCostUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intWeightUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intWeightUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblUnitCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblUnitRetail",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblLineTotal",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intGradeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblGross",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblNet",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strOrderNumber",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strSourceNumber",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strItemNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strItemDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strOwnershipType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strLotTracking",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strWeightUOM",
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
        "name": "strUnitType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strContainer",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblGrossMargin",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intCommodityId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intTaxGroupId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intLoadReceive",
        "type": "int",
        "allowNull": false
    }, {
        "name": "ysnSubCurrency",
        "type": "boolean",
        "allowNull": true
    }, {
        "name": "strSubCurrency",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strPricingType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strTaxGroup",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intForexRateTypeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strForexRateType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblForexRate",
        "type": "float",
        "allowNull": true
    }, {
        "name": "ysnLotWeightsRequired",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "dblOpenReceiveBeforeEdit",
        "type": "float",
        "allowNull": true
    }, {
        "name": "dblGrossBeforeEdit",
        "type": "float",
        "allowNull": true
    }, {
        "name": "dblNetBeforeEdit",
        "type": "float",
        "allowNull": true
    }, {
        "name": "strChargesLink",
        "type": "string",
        "allowNull": true
    }, {
        "name": "strItemType",
        "type": "string",
        "allowNull": true
    }, {
        "name": "intParentItemLinkId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intChildItemLinkId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intContractSeq",
        "type": "int",
        "allowNull": true
    }],
    validators: [
        [{
            "field": "strItemNo",
            "type": "presence"
        }, {
            "field": "strOwnershipType",
            "type": "presence"
        }, {
            "field": "strUnitMeasure",
            "type": "presence"
        }, {
            "field": "dblOpenReceive",
            "type": "presence"
        }]
    ]
});