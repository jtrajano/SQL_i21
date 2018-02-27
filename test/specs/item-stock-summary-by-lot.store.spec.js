UnitTestEngine.testStore({
    name: 'Inventory.store.ItemStockSummaryByLot',
    alias: "store.icitemstocksummarybylot",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.ItemStockSummary"],
    config: {
        "model": "Inventory.model.ItemStockSummary",
        "storeId": "ItemStockSummaryByLot",
        "pageSize": 1000000,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/inventorycount/getitemstocksummarybylot"
            }
        }
    }
});