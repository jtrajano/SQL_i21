UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockUOMViewTotalsAllStorageUnits',
    alias: "store.icbuffereditemstockuomviewtotalsallstorageunits",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockUOMViewTotals"],
    config: {
        "model": "Inventory.model.ItemStockUOMViewTotals",
        "storeId": "BufferedItemStockUOMViewTotalsAllStorageUnits",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/itemstock/searchitemstockuomviewtotalsallstorageunits"
            }
        }
    }
});