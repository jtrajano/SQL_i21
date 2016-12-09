UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedMeasurement',
    alias: "store.icbufferedmeasurement",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Measurement"],
    config: {
        "model": "Inventory.model.Measurement",
        "storeId": "BufferedMeasurement",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Measurement/Search"
            }
        }
    }
});