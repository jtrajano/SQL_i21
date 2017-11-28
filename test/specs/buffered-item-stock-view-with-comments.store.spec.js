UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockViewWithComments',
    alias: "store.icbuffereditemstockviewwithcomments",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockView"],
    config: {
        "model": "Inventory.model.ItemStockView",
        "storeId": "BufferedItemStockViewWithComments",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/item/searchitemstockswithcomments"
            }
        }
    }
});