UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCategoryAccount',
    alias: "store.icbufferedcategoryaccount",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CategoryAccount"],
    config: {
        "model": "Inventory.model.CategoryAccount",
        "storeId": "BufferedCategoryAccount",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CategoryAccount/Search"
            }
        }
    }
});