UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedFeedStockUom',
    alias: "store.icbufferedfeedstockuom",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.FeedStockUom"],
    config: {
        "model": "Inventory.model.FeedStockUom",
        "storeId": "BufferedFeedStockUom",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/FeedStockUOM/Search"
            }
        }
    }
});