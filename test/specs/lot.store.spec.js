UnitTestEngine.testStore({
    name: 'Inventory.store.Lot',
    alias: "store.iclot",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.Lot"],
    config: {
        "model": "Inventory.model.Lot",
        "storeId": "Lot",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/lot/get"
            }
        }
    }
});