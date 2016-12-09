UnitTestEngine.testStore({
    name: 'Inventory.store.ReceiptItemTax',
    alias: "store.icreceiptitemtax",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.ReceiptItemTax"],
    config: {
        "model": "Inventory.model.ReceiptItemTax",
        "storeId": "ReceiptItemTax",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/InventoryReceiptItemTax/GetReceiptItemTaxView",
                "update": "../Inventory/api/InventoryReceiptItemTax/Put",
                "create": "../Inventory/api/InventoryReceiptItemTax/Post"
            }
        }
    }
});