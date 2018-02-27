UnitTestEngine.testStore({
    name: 'Inventory.store.Item',
    alias: "store.icitem",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.Item"],
    config: {
        "model": "Inventory.model.Item",
        "storeId": "Item",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/item/get",
                "update": "./inventory/api/item/put",
                "create": "./inventory/api/item/post"
            }
        }
    }
});