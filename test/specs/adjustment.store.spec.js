UnitTestEngine.testStore({
    name: 'Inventory.store.Adjustment',
    alias: "store.icadjustment",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.Adjustment"],
    config: {
        "model": "Inventory.model.Adjustment",
        "storeId": "Adjustment",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/inventoryadjustment/get",
                "update": "./inventory/api/inventoryadjustment/put",
                "create": "./inventory/api/inventoryadjustment/post"
            }
        }
    }
});