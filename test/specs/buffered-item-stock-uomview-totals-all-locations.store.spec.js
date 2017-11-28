UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockUOMViewTotalsAllLocations',
    alias: "store.icbuffereditemstockuomviewtotalsalllocations",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockUOMViewTotals"],
    config: {
        "model": "Inventory.model.ItemStockUOMViewTotals",
        "storeId": "BufferedItemStockUOMViewTotalsAllLocations",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/itemstock/searchitemstockuomviewtotalsalllocations"
            }
        }
    }
});