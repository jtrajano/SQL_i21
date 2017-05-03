UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedProductTypeAttribute',
    alias: "store.icbufferedproducttypeattribute",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CommodityProductType"],
    config: {
        "model": "Inventory.model.CommodityProductType",
        "storeId": "BufferedProductTypeAttribute",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CommodityAttribute/SearchProductTypeAttributes"
            }
        }
    }
});