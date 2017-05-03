UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemCommodity',
    alias: "store.icbuffereditemcommodity",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CompactItem"],
    config: {
        "model": "Inventory.model.CompactItem",
        "storeId": "BufferedItemCommodity",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/SearchItemCommodities"
            }
        }
    }
});