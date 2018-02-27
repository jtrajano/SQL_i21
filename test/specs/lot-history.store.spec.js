UnitTestEngine.testStore({
    name: 'Inventory.store.LotHistory',
    alias: "store.iclothistory",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.LotHistory"],
    config: {
        "model": "Inventory.model.LotHistory",
        "storeId": "LotHistory",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/lot/gethistory"
            }
        }
    }
});