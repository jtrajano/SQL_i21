UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCategoryVendor',
    alias: "store.icbufferedcategoryvendor",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CategoryVendor"],
    config: {
        "model": "Inventory.model.CategoryVendor",
        "storeId": "BufferedCategoryVendor",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CategoryVendor/Search"
            }
        }
    }
});