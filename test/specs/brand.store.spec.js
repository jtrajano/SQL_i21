UnitTestEngine.testStore({
    name: 'Inventory.store.Brand',
    alias: "store.icbrand",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.Brand"],
    config: {
        "model": "Inventory.model.Brand",
        "storeId": "Brand",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/brand/get",
                "update": "./inventory/api/brand/put",
                "create": "./inventory/api/brand/post"
            }
        }
    }
});