UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedRegionAttribute',
    alias: "store.icbufferedregionattribute",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CommodityRegion"],
    config: {
        "model": "Inventory.model.CommodityRegion",
        "storeId": "BufferedRegionAttribute",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CommodityAttribute/SearchRegionAttributes"
            }
        }
    }
});