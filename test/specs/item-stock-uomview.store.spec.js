UnitTestEngine.testStore({
    name: 'Inventory.store.ItemStockUOMView',
    alias: "store.icitemstockuomview",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.ItemStockUOMView"],
    config: {
        "model": "Inventory.model.ItemStockUOMView",
        "storeId": "ItemStockUOMView",
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