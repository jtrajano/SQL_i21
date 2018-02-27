UnitTestEngine.testStore({
    name: 'Inventory.store.Receipt',
    alias: "store.icreceipt",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.Receipt"],
    config: {
        "model": "Inventory.model.Receipt",
        "storeId": "Receipt",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/inventoryreceipt/get",
                "update": "./inventory/api/inventoryreceipt/put",
                "create": "./inventory/api/inventoryreceipt/post"
            }
        }
    }
});