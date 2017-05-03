UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedProductLineAttribute',
    alias: "store.icbufferedproductlineattribute",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CommodityProductLine"],
    config: {
        "model": "Inventory.model.CommodityProductLine",
        "storeId": "CommodityProductLine",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CommodityAttribute/SearchProductLineAttributes"
            }
        }
    }
});