UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedReceiptItemView',
    alias: "store.icbufferedreceiptitemview",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ReceiptItemView"],
    config: {
        "model": "Inventory.model.ReceiptItemView",
        "storeId": "BufferedReceiptItemView",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/inventoryreceipt/searchreceiptitemview"
            },
            "extraParams": [{
                "name": "intInventoryReceiptId",
                "value": "156"
            }]
        }
    }
});