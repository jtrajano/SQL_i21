UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockSummaryByLot',
    alias: "store.icbuffereditemstocksummarybylot",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockSummary"],
    config: {
        "model": "Inventory.model.ItemStockSummary",
        "storeId": "BufferedItemStockSummaryByLot",
        "pageSize": 50,
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