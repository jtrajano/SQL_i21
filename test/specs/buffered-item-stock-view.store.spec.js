UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockView',
    alias: "store.icbuffereditemstockview",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockView"],
    config: {
        "model": "Inventory.model.ItemStockView",
        "storeId": "BufferedItemStockView",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/SearchItemStocks"
            }
        }
    }
});