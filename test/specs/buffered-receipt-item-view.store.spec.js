Inventory.TestUtils.testStore({
    name: 'Inventory.store.BufferedReceiptItemView',
    alias: "store.icbufferedreceiptitemview",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.ReceiptItemView"],
    config: {
        "model": "Inventory.model.ReceiptItemView",
        "storeId": "BufferedReceiptItemView",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/InventoryReceipt/SearchReceiptItemView"
            },
            "extraParams": [{
                "name": "intInventoryReceiptId",
                "value": "156"
            }]
        }
    }
});