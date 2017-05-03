UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemPricingView',
    alias: "store.icbuffereditempricingview",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockDetailPricing"],
    config: {
        "model": "Inventory.model.ItemStockDetailPricing",
        "storeId": "BufferedItemPricingView",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ItemPricing/SearchItemPricingViews"
            }
        }
    }
});