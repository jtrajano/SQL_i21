UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockUOMForAdjustmentView',
    alias: "store.icbuffereditemstockuomforadjustmentview",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockUOMForAdjustmentView"],
    config: {
        "model": "Inventory.model.ItemStockUOMForAdjustmentView",
        "storeId": "BufferedItemStockUOMForAdjustmentView",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ItemStock/SearchItemStockUOMForAdjustment"
            }
        }
    }
});