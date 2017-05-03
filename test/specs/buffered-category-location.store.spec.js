UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCategoryLocation',
    alias: "store.icbufferedcategorylocation",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CategoryLocation"],
    config: {
        "model": "Inventory.model.CategoryLocation",
        "storeId": "BufferedCategoryLocation",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CategoryLocation/Search"
            }
        }
    }
});