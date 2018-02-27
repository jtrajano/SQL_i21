UnitTestEngine.testStore({
    name: 'Inventory.store.ReceiptItemTax',
    alias: "store.icreceiptitemtax",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.ReceiptItemTax"],
    config: {
        "model": "Inventory.model.ReceiptItemTax",
        "storeId": "ReceiptItemTax",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/inventoryreceiptitemtax/getreceiptitemtaxview",
                "update": "./inventory/api/inventoryreceiptitemtax/put",
                "create": "./inventory/api/inventoryreceiptitemtax/post"
            }
        }
    }
});