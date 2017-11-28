UnitTestEngine.testStore({
    name: 'Inventory.store.Category',
    alias: "store.iccategory",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Category"],
    config: {
        "model": "Inventory.model.Category",
        "storeId": "Category",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/category/get",
                "update": "./inventory/api/category/put",
                "create": "./inventory/api/category/post"
            }
        }
    }
});