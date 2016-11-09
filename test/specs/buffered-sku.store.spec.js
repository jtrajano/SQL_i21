UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedSku',
    alias: "store.icbufferedsku",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Sku"],
    config: {
        "model": "Inventory.model.Sku",
        "storeId": "BufferedSku",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Sku/Search"
            }
        }
    }
});