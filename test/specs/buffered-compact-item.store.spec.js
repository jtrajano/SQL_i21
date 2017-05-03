UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCompactItem',
    alias: "store.icbufferedcompactitem",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CompactItem"],
    config: {
        "model": "Inventory.model.CompactItem",
        "storeId": "BufferedCompactItem",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/SearchCompactItems"
            }
        }
    }
});