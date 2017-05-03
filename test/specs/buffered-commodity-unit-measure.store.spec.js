UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCommodityUnitMeasure',
    alias: "store.icbufferedcommodityunitmeasure",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CommodityUnitMeasure"],
    config: {
        "model": "Inventory.model.CommodityUnitMeasure",
        "storeId": "BufferedCommodityUnitMeasure",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CommodityUOM/Search"
            }
        }
    }
});