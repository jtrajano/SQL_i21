UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedStockTrackingItemView',
    alias: "store.icbufferedstocktrackingitemview",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockView"],
    config: {
        "model": "Inventory.model.ItemStockView",
        "storeId": "BufferedStockTrackingItemView",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/SearchStockTrackingItems"
            }
        }
    }
});