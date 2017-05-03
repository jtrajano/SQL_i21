UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockDetailView',
    alias: "store.icbuffereditemstockdetailview",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockDetailView"],
    config: {
        "model": "Inventory.model.ItemStockDetailView",
        "storeId": "BufferedItemStockDetailView",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/SearchItemStockDetails"
            }
        }
    }
});