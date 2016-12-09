UnitTestEngine.testStore({
    name: 'Inventory.store.ItemStockSummaryByLot',
    alias: "store.icitemstocksummarybylot",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.ItemStockSummary"],
    config: {
        "model": "Inventory.model.ItemStockSummary",
        "storeId": "ItemStockSummaryByLot",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/InventoryCount/GetItemStockSummaryByLot"
            }
        }
    }
});