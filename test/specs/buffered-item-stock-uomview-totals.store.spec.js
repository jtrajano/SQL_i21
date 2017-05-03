UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockUOMViewTotals',
    alias: "store.icbuffereditemstockuomviewtotals",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockUOMViewTotals"],
    config: {
        "model": "Inventory.model.ItemStockUOMViewTotals",
        "storeId": "BufferedItemStockUOMViewTotals",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ItemStock/SearchItemStockUOMViewTotals"
            }
        }
    }
});