UnitTestEngine.testStore({
    name: 'Inventory.store.ItemStockUOMView',
    alias: "store.icitemstockuomview",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
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
                "read": "./inventory/api/itemstock/searchitemstockuoms"
            }
        }
    }
});