UnitTestEngine.testStore({
    name: 'Inventory.store.FeedStockUom',
    alias: "store.icfeedstockuom",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.FeedStockUom"],
    config: {
        "model": "Inventory.model.FeedStockUom",
        "storeId": "FeedStockUom",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/feedstockuom/get",
                "update": "./inventory/api/feedstockuom/put",
                "create": "./inventory/api/feedstockuom/post"
            }
        }
    }
});