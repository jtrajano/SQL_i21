UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedFeedStockCode',
    alias: "store.icbufferedfeedstockcode",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.FeedStockCode"],
    config: {
        "model": "Inventory.model.FeedStockCode",
        "storeId": "BufferedFeedStockCode",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/FeedStock/Search"
            }
        }
    }
});