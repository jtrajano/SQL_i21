UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockUOMView',
    alias: "store.icbuffereditemstockuomview",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockUOMView"],
    config: {
        "model": "Inventory.model.ItemStockUOMView",
        "storeId": "BufferedItemStockUOMView",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ItemStock/SearchItemStockUOMs"
            }
        }
    }
});