var getReceipt = function () {
    var receipt = Ext.create('Inventory.model.Receipt', {
        strReceiptType: "Direct",
        strReceiptNumber: "IR-1074",
        dtmReceiptDate: "2018-02-22T00:00:00",
        intItemCount: 1
    });
    return receipt;
}

var getReceiptItem = function () {
    var item = Ext.create('Inventory.model.ReceiptItem', {
        dblOpenReceive: 5000.00,
        dblUnitCost: 1.00,
        dblLineTotal: 5000.00,
        dblGross: 5000.00,
        dblNet: 5000.00,
        strItemNo: "Receipt Item",
        strItemDescription: "Receipt Item",
        strLotTracking: "Yes - Manual/Serial Number",
        strUnitMeasure: "KG",
        strUnitType: "Weight",
        dblItemUOMConvFactor: 1.00,
        dblWeightUOMConvFactor: 1.00,
        strCostUOM: "KG",
        dblCostUOMConvFactor: 1.00,
        dblAvailableQty: null,
        tblICInventoryReceiptItemLots: getLots()
    });
    return item;
}

var getReceiptItemLot = function () {
    return getLots()[1];
}

var getLots = function () {
    return [
        Ext.create('Inventory.model.ReceiptItemLot', {
            dblQuantity: 1,
            dblGrossWeight: 1000,
            dblTareWeight: 0,
            dblNetWeight: 1000,
            strUnitMeasure: "Ton",
            strUnitType: "Quantity",
            dblUnitQty: 1000.00,
            dblLotUOMConvFactor: 1000.00
        }),
        Ext.create('Inventory.model.ReceiptItemLot', {
            dblQuantity: 300,
            dblGrossWeight: 300,
            dblTareWeight: 28.785492111975564,
            dblNetWeight: 271.21,
            strUnitMeasure: "KG",
            strUnitType: "Weight",
            dblUnitQty: 1.00,
            strItemUOM: "KG",
            dblLotUOMConvFactor: 1.00
        })
    ];
}

var getLotsSmall = function () {
    return [
        Ext.create('Inventory.model.ReceiptItemLot', {
            dblQuantity: 1,
            dblGrossWeight: 1000,
            dblTareWeight: 0,
            dblNetWeight: 1000,
            strUnitMeasure: "Ton",
            strUnitType: "Quantity",
            dblUnitQty: 1000.00,
            dblLotUOMConvFactor: 1000.00
        }),
        Ext.create('Inventory.model.ReceiptItemLot', {
            dblQuantity: 0.005,
            dblGrossWeight: 0.005,
            dblTareWeight: 0,
            dblNetWeight: 0.005,
            strUnitMeasure: "KG",
            strUnitType: "Weight",
            dblUnitQty: 1.00,
            strItemUOM: "KG",
            dblLotUOMConvFactor: 1.00
        })
    ];
}