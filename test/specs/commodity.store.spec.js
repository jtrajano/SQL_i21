UnitTestEngine.testStore({
    name: 'Inventory.store.Commodity',
    alias: "store.iccommodity",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Commodity"],
    config: {
        "model": "Inventory.model.Commodity",
        "storeId": "Commodity",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/commodity/get",
                "update": "./inventory/api/commodity/put",
                "create": "./inventory/api/commodity/post"
            }
        }
    }
});