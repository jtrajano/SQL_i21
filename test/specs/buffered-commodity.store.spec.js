UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCommodity',
    alias: "store.icbufferedcommodity",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CompactCommodity"],
    config: {
        "model": "Inventory.model.CompactCommodity",
        "storeId": "BufferedCommodity",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Commodity/Search"
            }
        }
    }
});