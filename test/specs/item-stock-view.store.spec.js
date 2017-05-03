UnitTestEngine.testStore({
    name: 'Inventory.store.ItemStockView',
    alias: "store.icitemstockview",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.ItemStockView"],
    config: {
        "model": "Inventory.model.ItemStockView",
        "storeId": "ItemStockView",
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