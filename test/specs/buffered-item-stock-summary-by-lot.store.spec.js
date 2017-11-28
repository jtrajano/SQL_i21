UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockSummaryByLot',
    alias: "store.icbuffereditemstocksummary",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockSummary"],
    config: {
        "model": "Inventory.model.ItemStockSummary",
        "storeId": "BufferedItemStockSummary",
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