UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedClassAttribute',
    alias: "store.icbufferedclassattribute",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CommodityClass"],
    config: {
        "model": "Inventory.model.CommodityClass",
        "storeId": "BufferedClassAttribute",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CommodityAttribute/SearchClassAttributes"
            }
        }
    }
});