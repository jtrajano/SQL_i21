UnitTestEngine.testStore({
    name: 'Inventory.store.ItemStockSummary',
    alias: "store.icitemstocksummary",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.ItemStockSummary"],
    config: {
        "model": "Inventory.model.ItemStockSummary",
        "storeId": "ItemStockSummary",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/InventoryCount/SearchItemStockSummary"
            }
        }
    }
});