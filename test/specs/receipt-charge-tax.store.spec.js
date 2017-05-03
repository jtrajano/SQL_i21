UnitTestEngine.testStore({
    name: 'Inventory.store.ReceiptChargeTax',
    alias: "store.icreceiptchargetax",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.ReceiptChargeTax"],
    config: {
        "model": "Inventory.model.ReceiptChargeTax",
        "storeId": "ReceiptItemTax",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/InventoryReceiptChargeTax/GetReceiptChargeTaxView",
                "update": "../Inventory/api/InventoryReceiptChargeTax/Put",
                "create": "../Inventory/api/InventoryReceiptChargeTax/Post"
            }
        }
    }
});