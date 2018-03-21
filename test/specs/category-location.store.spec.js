UnitTestEngine.testStore({
    name: 'Inventory.store.CategoryLocation',
    alias: "store.iccategorylocation",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.CategoryLocation"],
    config: {
        "model": "Inventory.model.CategoryLocation",
        "storeId": "CategoryLocation",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/categorylocation/getcategorylocation",
                "update": "./inventory/api/categorylocation/put",
                "create": "./inventory/api/categorylocation/post"
            }
        }
    }
});