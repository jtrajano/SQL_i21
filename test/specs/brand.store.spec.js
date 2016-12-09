UnitTestEngine.testStore({
    name: 'Inventory.store.Brand',
    alias: "store.icbrand",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Brand"],
    config: {
        "model": "Inventory.model.Brand",
        "storeId": "Brand",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Brand/Get",
                "update": "../Inventory/api/Brand/Put",
                "create": "../Inventory/api/Brand/Post"
            }
        }
    }
});