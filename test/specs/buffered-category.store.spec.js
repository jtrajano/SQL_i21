UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCategory',
    alias: "store.icbufferedcategory",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Category"],
    config: {
        "model": "Inventory.model.Category",
        "storeId": "BufferedCategory",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Category/Search"
            }
        }
    }
});