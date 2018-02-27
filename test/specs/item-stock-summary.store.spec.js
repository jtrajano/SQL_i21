UnitTestEngine.testStore({
    name: 'Inventory.store.ItemStockSummary',
    alias: "store.icitemstocksummary",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.ItemStockSummary"],
    config: {
        "model": "Inventory.model.ItemStockSummary",
        "storeId": "ItemStockSummary",
        "pageSize": 1000000,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/inventorycount/searchitemstocksummary"
            }
        }
    }
});