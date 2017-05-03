UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedOriginAttribute',
    alias: "store.icbufferedoriginattribute",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CommodityOrigin"],
    config: {
        "model": "Inventory.model.CommodityOrigin",
        "storeId": "BufferedOriginAttribute",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CommodityAttribute/SearchOriginAttributes"
            }
        }
    }
});