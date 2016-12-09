UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCategoryUOM',
    alias: "store.icbufferedcategoryuom",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CategoryUOM"],
    config: {
        "model": "Inventory.model.CategoryUOM",
        "storeId": "BufferedCategoryUOM",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CategoryUOM/Search"
            }
        }
    }
});