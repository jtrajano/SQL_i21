UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedSeasonAttribute',
    alias: "store.icbufferedseasonattribute",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CommoditySeason"],
    config: {
        "model": "Inventory.model.CommoditySeason",
        "storeId": "BufferedSeasonAttribute",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CommodityAttribute/SearchSeasonAttributes"
            }
        }
    }
});