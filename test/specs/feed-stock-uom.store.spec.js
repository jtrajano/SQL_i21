UnitTestEngine.testStore({
    name: 'Inventory.store.FeedStockUom',
    alias: "store.icfeedstockuom",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.FeedStockUom"],
    config: {
        "model": "Inventory.model.FeedStockUom",
        "storeId": "FeedStockUom",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/FeedStockUOM/Get",
                "update": "../Inventory/api/FeedStockUOM/Put",
                "create": "../Inventory/api/FeedStockUOM/Post"
            }
        }
    }
});