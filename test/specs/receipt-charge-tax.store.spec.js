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
                "read": "./inventory/api/inventoryreceiptchargetax/getreceiptchargetaxview",
                "update": "./inventory/api/inventoryreceiptchargetax/put",
                "create": "./inventory/api/inventoryreceiptchargetax/post"
            }
        }
    }
});