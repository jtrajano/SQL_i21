UnitTestEngine.testStore({
    name: 'Inventory.store.FeedStockCode',
    alias: "store.icfeedstockcode",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.FeedStockCode"],
    config: {
        "model": "Inventory.model.FeedStockCode",
        "storeId": "FeedStockCode",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/FeedStock/Get",
                "update": "../Inventory/api/FeedStock/Put",
                "create": "../Inventory/api/FeedStock/Post"
            }
        }
    }
});