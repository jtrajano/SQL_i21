UnitTestEngine.testStore({
    name: 'Inventory.store.LotStatus',
    alias: "store.iclotstatus",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.LotStatus"],
    config: {
        "model": "Inventory.model.LotStatus",
        "storeId": "LotStatus",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/lotstatus/get",
                "update": "./inventory/api/lotstatus/put",
                "create": "./inventory/api/lotstatus/post"
            }
        }
    }
});