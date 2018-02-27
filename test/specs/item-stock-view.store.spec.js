UnitTestEngine.testStore({
    name: 'Inventory.store.ItemStockView',
    alias: "store.icitemstockview",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
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
                "read": "./inventory/api/item/searchitemstocks"
            }
        }
    }
});